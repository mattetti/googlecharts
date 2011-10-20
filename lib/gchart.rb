$:.unshift File.dirname(__FILE__)
require 'gchart/version'
require 'gchart/theme'
require "net/http"
require "net/https"
require "uri"
require "cgi"
require 'enumerator'

class Gchart
  include GchartInfo

  def self.url(use_ssl = false)
    if use_ssl
      'https://chart.googleapis.com/chart?'
    else
      'http://chart.apis.google.com/chart?'
    end
  end

  def self.types
    @types ||= ['line', 'line_xy', 'scatter', 'bar', 'venn', 'pie', 'pie_3d', 'jstize', 'sparkline', 'meter', 'map', 'radar']
  end

  def self.simple_chars
    @simple_chars ||= ('A'..'Z').to_a + ('a'..'z').to_a + ('0'..'9').to_a
  end 

  def self.chars
    @chars ||= simple_chars + ['-', '.']
  end

  def self.ext_pairs
    @ext_pairs ||= chars.map { |char_1| chars.map { |char_2| char_1 + char_2 } }.flatten
  end

  def self.default_filename
    'chart.png'
  end

  attr_accessor :title, :type, :width, :height, :curved, :horizontal, :grouped, :legend, :legend_position, :labels, :data, :encoding, :bar_colors,
  :title_color, :title_size, :title_alignment, :custom, :axis_with_labels, :axis_labels, :bar_width_and_spacing, :id, :alt, :klass,
  :range_markers, :geographical_area, :map_colors, :country_codes, :axis_range, :filename, :min, :max, :colors, :usemap

  attr_accessor :bg_type, :bg_color, :bg_angle, :chart_type, :chart_color, :chart_angle, :axis_range, :thickness, :new_markers, :grid_lines, :use_ssl

  attr_accessor :min_value, :max_value
  
  types.each do |type|
    instance_eval <<-DYNCLASSMETH
    def #{type}(options = {})
      # Start with theme defaults if a theme is set
      theme = options[:theme]
      options = theme ? Chart::Theme.load(theme).to_options.merge(options) : options 
      # # Extract the format and optional filename, then clean the hash
      format = options[:format] || 'url'
      options[:filename] ||= default_filename
      options.delete(:format)
      #update map_colors to become bar_colors
      options.update(:bar_colors => options[:map_colors]) if options.has_key?(:map_colors)
      chart = new(options.merge!({:type => "#{type}"}))
      chart.send(format)
    end
    DYNCLASSMETH
  end

  def self.version
    VERSION::STRING
  end

  def self.method_missing(m, options={})
    raise NoMethodError, "#{m} is not a supported chart format. Please use one of the following: #{supported_types}."
  end

  def initialize(options={})
    @type = options[:type] || 'line'
    @data = []
    @width = 300
    @height = 200
    @curved = false
    @horizontal = false
    @grouped = false
    @use_ssl = false
    @encoding = 'simple'
    # @max_value = 'auto'
    # @min_value defaults to nil meaning zero
    @filename = options[:filename]
    # Sets the alt tag when chart is exported as image tag
    @alt = 'Google Chart'
    # Sets the CSS id selector when chart is exported as image tag
    @id = false
    # Sets the CSS class selector when chart is exported as image tag
    @klass = options[:class] || false
    # set the options value if definable
    options.each do |attribute, value| 
      send("#{attribute}=", value) if self.respond_to?("#{attribute}=")
    end
  end

  def self.supported_types
    self.types.join(' ')
  end

  # Defines the Graph size using the following format:
  # width X height
  def size=(size='300x200')
    @width, @height = size.split("x").map { |dimension| dimension.to_i }
  end
  
  def size
    "#{width}x#{height}"
  end
  
  def dimensions
    # TODO: maybe others?
    [:line_xy, :scatter].include?(type) ? 2 : 1
  end

  # Sets the orientation of a bar graph
  def orientation=(orientation='h')
    if orientation == 'h' || orientation == 'horizontal'
      self.horizontal = true
    elsif orientation == 'v' || orientation == 'vertical'
      self.horizontal = false
    end
  end

  # Sets the bar graph presentation (stacked or grouped)
  def stacked=(option=true)
    @grouped = option ? false : true
  end

  def bg=(options)
    if options.is_a?(String)
      @bg_color = options
    elsif options.is_a?(Hash)
      @bg_color = options[:color]
      @bg_type  = options[:type]
      @bg_angle = options[:angle]
    end
  end

  def graph_bg=(options)
    if options.is_a?(String)
      @chart_color = options
    elsif options.is_a?(Hash)
      @chart_color = options[:color]
      @chart_type  =  options[:type]
      @chart_angle = options[:angle]
    end
  end
  
  def max_value=(max_v)
    if max_v =~ /false/
      @max_value = false
    else
      @max_value = max_v
    end
  end

  def min_value=(min_v)
    if min_v =~ /false/
      @min_value = false
    else
      @min_value = min_v
    end
  end

  # returns the full data range as an array
  # it also sets the data range if not defined
  def full_data_range(ds)
    return if max_value == false

    ds.each_with_index do |mds, mds_index|
      mds[:min_value] ||= min_value
      mds[:max_value] ||= max_value
      
      if mds_index == 0 && type.to_s == 'bar'
        # TODO: unless you specify a zero line (using chp or chds),
        #       the min_value of a bar chart is always 0.
        #mds[:min_value] ||= mds[:data].first.to_a.compact.min
        mds[:min_value] ||= 0
      end
      if (mds_index == 0 && type.to_s == 'bar' && 
        !grouped && mds[:data].first.is_a?(Array))
        totals = []
        mds[:data].each do |l|
          l.each_with_index do |v, index|
            next if v.nil?
            totals[index] ||= 0
            totals[index] += v
          end
        end
        mds[:max_value] ||= totals.compact.max
      else
        all = mds[:data].flatten.compact
        # default min value should be 0 unless set to auto
        if mds[:min_value] == 'auto'
          mds[:min_value] = all.min
        else
          min = all.min
          mds[:min_value] ||=  (min && min < 0 ? min : 0)
        end
        mds[:max_value] ||= all.max
      end
    end

    unless axis_range
      @calculated_axis_range = true
      @axis_range = ds.map{|mds| [mds[:min_value], mds[:max_value]]}
      if dimensions == 1 && (type.to_s != 'bar' || horizontal)
        tmp = axis_range.fetch(0, [])
        @axis_range[0] = axis_range.fetch(1, [])
        @axis_range[1] = tmp
      end
    end
    # return [min, max] unless (min.nil? || max.nil?)
    # @max = (max_value.nil? || max_value == 'auto') ? ds.compact.map{|mds| mds.compact.max}.max : max_value
    # 
    # if min_value.nil? 
    #   min_ds_value = ds.compact.map{|mds| mds.compact.min}.min || 0
    #   @min = (min_ds_value < 0) ? min_ds_value : 0
    # else
    #   @min = min_value == 'auto' ? ds.compact.map{|mds| mds.compact.min}.min || 0 : min_value      
    # end
    # @axis_range = [[min,max]]
  end

  def dataset
    if @dataset
      @dataset 
    else
      @dataset = convert_dataset(data || [])
      full_data_range(@dataset)   # unless axis_range
      @dataset
    end
  end
  
  # Sets of data to handle multiple sets
  def datasets
    datasets = []
    dataset.each do |d|
      if d[:data].first.is_a?(Array)
        datasets += d[:data]
      else
        datasets << d[:data]
      end
    end
    datasets
  end
  
  def self.jstize(string)
    # See http://github.com/mattetti/googlecharts/issues#issue/27
    #URI.escape( string ).gsub("%7C", "|")
    # See discussion: http://github.com/mattetti/googlecharts/commit/9b5cfb93aa51aae06611057668e631cd515ec4f3#comment_51347
    string.gsub(' ', '+').gsub(/\[|\{|\}|\\|\^|\[|\]|\`|\]/) {|c| "%#{c[0].to_s.upcase}"}
    #string.gsub(' ', '+').gsub(/\[|\{|\}|\||\\|\^|\[|\]|\`|\]/) {|c| "%#{c[0].to_s.upcase}"}
  end    
  # load all the custom aliases
  require 'gchart/aliases'

  # Returns the chart's generated PNG as a blob. (borrowed from John's gchart.rubyforge.org)
  def fetch
    url = URI.parse(self.class.url(use_ssl))
    req = Net::HTTP::Post.new(url.path)
    req.body = query_builder
    req.content_type = 'application/x-www-form-urlencoded'
    http = Net::HTTP.new(url.host, url.port)
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER if use_ssl
    http.use_ssl = use_ssl
    http.start {|resp| resp.request(req) }.body
  end

  # Writes the chart's generated PNG to a file. (borrowed from John's gchart.rubyforge.org)
  def write
    io_or_file = filename || self.class.default_filename
    return io_or_file.write(fetch) if io_or_file.respond_to?(:write)
    open(io_or_file, "wb+") { |io| io.write(fetch) }
  end

  # Format

  def image_tag
    image = "<img"
    image += " id=\"#{id}\"" if id  
    image += " class=\"#{klass}\"" if klass      
    image += " src=\"#{url_builder(:html)}\""
    image += " width=\"#{width}\""
    image += " height=\"#{height}\""
    image += " alt=\"#{alt}\""
    image += " title=\"#{title}\"" if title
    image += " usemap=\"#{usemap}\"" if usemap
    image += " />"
  end

  alias_method :img_tag, :image_tag

  def url
    url_builder
  end

  def file
    write
  end

  #
  def jstize(string)
    self.class.jstize(string)
  end

  private

  # The title size cannot be set without specifying a color.
  # A dark key will be used for the title color if no color is specified 
  def set_title
    title_params = "chtt=#{title}"
    unless (title_color.nil? && title_size.nil? && title_alignment.nil?)
      title_params << "&chts=" + (color, size, alignment = (title_color || '454545'), title_size, (title_alignment.to_s[0,1] || 'c')).compact.join(',')
    end
    title_params
  end

  def set_size
    "chs=#{size}"
  end

  def set_data
    data = send("#{@encoding}_encoding")
    "chd=#{data}"
  end

  def set_colors
    @bg_type = fill_type(bg_type) || 's' if bg_color
    @chart_type = fill_type(chart_type) || 's' if chart_color

    "chf=" + {'bg' => fill_for(bg_type, bg_color, bg_angle), 'c' => fill_for(chart_type, chart_color, chart_angle)}.map{|k,v| "#{k},#{v}" unless v.nil?}.compact.join('|')      
  end

  # set bar, line colors
  def set_bar_colors
    @bar_colors = bar_colors.join(',') if bar_colors.is_a?(Array)
    "chco=#{bar_colors}"
  end

  def set_country_codes
    @country_codes = country_codes.join() if country_codes.is_a?(Array)
    "chld=#{country_codes}"
  end

  # set bar spacing
  # chbh=
  # <bar width in pixels>,
  # <optional space between bars in a group>,
  # <optional space between groups>
  def set_bar_width_and_spacing
    width_and_spacing_values = case bar_width_and_spacing
    when String
      bar_width_and_spacing
    when Array
      bar_width_and_spacing.join(',')
    when Hash
      width         = bar_width_and_spacing[:width] || 23
      spacing       = bar_width_and_spacing[:spacing] || 4
      group_spacing = bar_width_and_spacing[:group_spacing] || 8
      [width,spacing,group_spacing].join(',')
    else
      bar_width_and_spacing.to_s
    end
    "chbh=#{width_and_spacing_values}"
  end

  def set_range_markers
    markers = case range_markers
    when Hash
      set_range_marker(range_markers)
    when Array
      range_markers.collect{|marker| set_range_marker(marker)}.join('|')
    end
    "chm=#{markers}"
  end

  def set_range_marker(options)
    orientation = ['vertical', 'Vertical', 'V', 'v', 'R'].include?(options[:orientation]) ? 'R' : 'r'
    "#{orientation},#{options[:color]},0,#{options[:start_position]},#{options[:stop_position]}#{',1' if options[:overlaid?]}"  
  end

  def fill_for(type=nil, color='', angle=nil)
    unless type.nil? 
      case type
      when 'lg'
        angle ||= 0
        color = "#{color},0,ffffff,1" if color.split(',').size == 1
        "#{type},#{angle},#{color}"
      when 'ls'
        angle ||= 90
        color = "#{color},0.2,ffffff,0.2" if color.split(',').size == 1
        "#{type},#{angle},#{color}"
      else
        "#{type},#{color}"
      end
    end
  end

  # A chart can have one or many legends. 
  # Gchart.line(:legend => 'label')
  # or
  # Gchart.line(:legend => ['first label', 'last label'])
  def set_legend
    if type.to_s =~ /meter/
      @labels = legend
      return set_labels
    end
    if legend.is_a?(Array)
      "chdl=#{@legend.map{|label| "#{CGI::escape(label.to_s)}"}.join('|')}"
    else
      "chdl=#{legend}"
    end

  end

  def set_legend_position
    case @legend_position.to_s
    when /(bottom|b)$/
      "chdlp=b"
    when /(bottom_vertical|bv)$/
      "chdlp=bv"
    when /(top|t)$/
      "chdlp=t"
    when /(top_vertical|tv)$/
      "chdlp=tv"
    when /(right|r)$/
      "chdlp=r"
    when /(left|l)$/
      "chdlp=l"
    end
  end

  def set_line_thickness
    "chls=#{thickness}"
  end

  def set_line_markers
    "chm=#{new_markers}"
  end

  def set_grid_lines
    "chg=#{grid_lines}"
  end

  def set_labels
    if labels.is_a?(Array)
      "chl=#{@labels.map{|label| "#{CGI::escape(label.to_s)}"}.join('|')}"
    else
      "chl=#{@labels}"
    end
  end

  def set_axis_with_labels
    @axis_with_labels = axis_with_labels.join(',') if @axis_with_labels.is_a?(Array)
    "chxt=#{axis_with_labels}"
  end

  def set_axis_labels
    if axis_labels.is_a?(Array)
      if RUBY_VERSION.to_f < 1.9
        labels_arr = axis_labels.enum_with_index.map{|labels,index| [index,labels]}
      else
        labels_arr = axis_labels.map.with_index.map{|labels,index| [index,labels]}
      end
    elsif axis_labels.is_a?(Hash)
      labels_arr = axis_labels.to_a
    end
    labels_arr.map! do |index,labels|
      if labels.is_a?(Array)
        "#{index}:|#{labels.map{|label| "#{CGI::escape(label.to_s)}"}.join('|')}"
      else
        "#{index}:|#{labels}"
      end
    end
    "chxl=#{labels_arr.join('|')}"
  end

  # http://code.google.com/apis/chart/labels.html#axis_range
  # Specify a range for axis labels
  def set_axis_range
    # a passed axis_range should look like:
    # [[10,100]] or [[10,100,4]] or [[10,100], [20,300]]
    # in the second example, 4 is the interval 
    set = @calculated_axis_range ? datasets : axis_range || datasets

    return unless set && set.respond_to?(:each) && set.find {|o| o}.respond_to?(:each)

    'chxr=' + set.enum_for(:each_with_index).map do |axis_range, index|
      next nil if axis_range.nil? # ignore this axis
      min, max, step = axis_range
      if axis_range.size > 3 || step && max && step > max # this is a full series
        max = axis_range.compact.max
        step = nil
      end
      [index, (min_value || min || 0), (max_value || max), step].compact.join(',')
    end.compact.join("|")
  end

  def set_geographical_area
    "chtm=#{geographical_area}"
  end

  def set_type
    'cht=' + case type.to_s
    when 'line'      then "lc"
    when 'line_xy'   then "lxy"
    when 'pie_3d'    then "p3"
    when 'pie'       then "p"
    when 'venn'      then "v"
    when 'scatter'   then "s"
    when 'sparkline' then "ls"
    when 'meter'     then "gom"
    when 'map'       then "t"
    when 'radar'
      "r" + (curved? ? 's' : '')
    when 'bar'
      "b" + (horizontal? ? "h" : "v") + (grouped? ? "g" : "s")
    end
  end

  def fill_type(type)
    case type
    when 'solid'    then 's'
    when 'gradient' then 'lg'
    when 'stripes'  then 'ls'
    end
  end
  
  def number_visible
    n = 0
    dataset.each do |mds|
      return n.to_s if mds[:invisible] == true
      if mds[:data].first.is_a?(Array)
        n += mds[:data].length
      else
        n += 1
      end
    end
    ""
  end
  
  # Turns input into an array of axis hashes, dependent on the chart type
  def convert_dataset(ds)
    if dimensions == 2
      # valid inputs include:
      # an array of >=2 arrays, or an array of >=2 hashes
      ds = ds.map do |d|
        d.is_a?(Hash) ? d : {:data => d}
      end
    elsif dimensions == 1
      # valid inputs include:
      # a hash, an array of data, an array of >=1 array, or an array of >=1 hash
      if ds.is_a?(Hash)
        ds = [ds]
      elsif not ds.first.is_a?(Hash)
        ds = [{:data => ds}]
      end
    end
    ds
  end
  
  # just an alias
  def axis_set
    dataset
  end

  def convert_to_simple_value(number)
    if number.nil?
      "_"
    else
      value = self.class.simple_chars[number.to_i]
      value.nil? ? "_" : value
    end
  end
  
  def convert_to_extended_value(number)
    if number.nil?
      '__'
    else
      value = self.class.ext_pairs[number.to_i]
      value.nil? ? "__" : value
    end
  end
  
  def encode_scaled_dataset(chars, nil_char)
    dsets = []
    dataset.each do |ds|
      if max_value != false
        range = ds[:max_value] - ds[:min_value]
        range = 1 if range == 0
      end
      unless ds[:data].first.is_a?(Array)
        ldatasets = [ds[:data]]
      else
        ldatasets = ds[:data]
      end
      ldatasets.each do |l|
        dsets << l.map do |number|
          if number.nil?
            nil_char
          else
            unless range.nil? || range.zero?
              number = chars.size * (number - ds[:min_value]) / range.to_f
              number = [number, chars.size - 1].min
            end
            chars[number.to_i]
          end
        end.join
      end
    end
    dsets.join(',')
  end

  # http://code.google.com/apis/chart/#simple
  # Simple encoding has a resolution of 62 different values. 
  # Allowing five pixels per data point, this is sufficient for line and bar charts up
  # to about 300 pixels. Simple encoding is suitable for all other types of chart regardless of size.
  def simple_encoding
    "s" + number_visible + ":" + encode_scaled_dataset(self.class.simple_chars, '_')
  end

  # http://code.google.com/apis/chart/#text
  # Text encoding with data scaling lets you specify arbitrary positive or
  # negative floating point numbers, in combination with a scaling parameter
  # that lets you specify a custom range for your chart. This chart is useful
  # when you don't want to worry about limiting your data to a specific range,
  # or do the calculations to scale your data down or up to fit nicely inside
  # a chart.
  #
  # Valid values range from (+/-)9.999e(+/-)100, and only four non-zero digits are supported (that is, 123400, 1234, 12.34, and 0.1234 are valid, but 12345, 123.45 and 123400.5 are not).
  #
  # This encoding is not available for maps.
  #
  def text_encoding
    chds = dataset.map{|ds| "#{ds[:min_value]},#{ds[:max_value]}" }.join(",")
    "t" + number_visible + ":" + datasets.map{ |ds| ds.map{|e|e||'_'}.join(',') }.join('|') + "&chds=" + chds
  end

  # http://code.google.com/apis/chart/#extended
  # Extended encoding has a resolution of 4,096 different values 
  # and is best used for large charts where a large data range is required.
  def extended_encoding
    "e" + number_visible + ":" + encode_scaled_dataset(self.class.ext_pairs, '__')
  end

  def url_builder(options="")
    self.class.url(use_ssl) + query_builder(options)
  end

  def query_builder(options="")
    query_params = instance_variables.sort.map do |var|
      case var.to_s
      when '@data'
        set_data unless data == []  
        # Set the graph size  
      when '@width'
        set_size unless width.nil? || height.nil?
      when '@type'
        set_type
      when '@title'
        set_title unless title.nil?
      when '@legend'
        set_legend unless legend.nil?
      when '@labels'
        set_labels unless labels.nil?
      when '@legend_position'
        set_legend_position unless legend_position.nil?
      when '@thickness'
        set_line_thickness
      when '@new_markers'
          set_line_markers
      when '@bg_color'
        set_colors
      when '@chart_color'
        set_colors if bg_color.nil?
      when '@bar_colors'
        set_bar_colors
      when '@bar_width_and_spacing'
        set_bar_width_and_spacing
      when '@axis_with_labels'
        set_axis_with_labels
      when '@axis_labels'
        set_axis_labels
      when '@range_markers'
        set_range_markers
      when '@grid_lines'
        set_grid_lines
      when '@geographical_area'
        set_geographical_area
      when '@country_codes'
        set_country_codes
      when '@custom'
        custom
      end
    end.compact

    query_params << set_axis_range

    # Use ampersand as default delimiter
    unless options == :html
      delimiter = '&'
      # Escape ampersand for html image tags
    else
      delimiter = '&amp;'
    end

    jstize(query_params.join(delimiter))
  end

end
