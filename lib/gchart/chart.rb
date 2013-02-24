module Gchart
  class Chart
    attr_reader :horizontal, :overlapped, :grouped

    def initialize(options = {})
      # Start with theme defaults if a theme is set
      theme = options[:theme]
      options = theme ? Theme.load(theme).to_options.merge(options) : options
      # # Extract the format and optional filename, then clean the hash
      @format = options[:format] || 'url'
      options[:filename] ||= default_filename
      options.delete(:format)
      set_orientation(options.delete(:orientation))
      set_overlapped(options.delete(:overlapped))
      set_grouped(options.delete(:grouped))
      #update map_colors to become bar_colors
      options.update(:bar_colors => options[:map_colors]) if options.has_key?(:map_colors)
      #sending self to Gchart just a temp fix
      @chart = Gchart.new(options.merge!({:type => self.class.to_s.downcase.gsub('gchart::', '')}), self)
    end

    def draw
      @chart.send(@format)
    end

    private

    def default_filename
      'chart.png'
    end

    def set_orientation(orientation)
      @horizontal = %w(h horizontal).include?(orientation) ? true : false
    end

    def set_overlapped(overlapped=false)
      @overlapped = overlapped
    end

    def set_grouped(grouped=false)
      @grouped = grouped
    end
  end
end
