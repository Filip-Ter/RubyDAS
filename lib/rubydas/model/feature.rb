require 'rubygems'
require 'data_mapper' # requires all the gems listed above

class Feature
  include DataMapper::Resource

  property :id,          Serial    # An auto-increment integer key
  property :public_id,   String, :length => 255    # An auto-increment integer key
  property :label,       String, :length => 255    # A varchar type string, for short strings
  property :parent,      String, :length => 255    #parent of current feature, can be null
  property :start,       Integer      # A text block, for longer string data.
  property :end,         Integer      # A text block, for longer string data.
  property :method,      String  # A DateTime, for any date you might like.
  property :score,       Float
  property :phase,       Enum[ '0', '1', '2', '-' ]
  property :orientation, Enum[ '0', '-', '+' ]

  has n, :links
  has n, :notes
  has n, :targets
#  has n, :parents, self
#  has n, :parts, self
  
  belongs_to :feature_type 
  belongs_to :segment

  def to_s 
      return "#{public_id} #{label} #{start}..#{self.end}"
  end

  def self.make(attrs)

      ft = attrs.delete(:type)
      attrs[:feature_type] = FeatureType.first_or_create(:label => ft) if ft

      seg = attrs.delete(:segment_id)
      attrs[:segment] = Segment.first_or_create(:public_id => seg, :label => seg) if seg

      @parent = attrs[:parent]

      relationships = {
          :links => Link,
          :notes => Note,
          :targets => Target
      }

      assocs = Hash[relationships.map { |k, v| [k, (attrs.delete(k) || []).map {|x| v.create(x)}]}]
      f = Feature.new(attrs)

      assocs.each do |k, v|
          f.send(k).concat(v)
      end

      unless f.save
          f.errors.each do |e|
              puts e
          end
          return nil
      end

      f
  end
  
end

class Target
  include DataMapper::Resource

  property :id, Serial
  property :start,       Integer      # A text block, for longer string data.
  property :stop,       Integer      # A text block, for longer string data.
  property :name, String

  belongs_to :feature
end

class Note
  include DataMapper::Resource

  property :id, Serial
  property :text, String
  belongs_to :feature

end

class Link
  include DataMapper::Resource

  property :id, Serial
  property :href, String
  property :link_text, String 
  
  belongs_to :feature
end

class Segment
    include DataMapper::Resource
    property :id, Serial
    property :public_id, String
    property :segment_type, String
    property :label, String

    has n, :features
end

class FeatureType
  include DataMapper::Resource
  
  property :id, Serial
  property :category, String
  property :reference, Boolean
  property :label, String

  has n, :features
  
end
 
DataMapper.finalize


