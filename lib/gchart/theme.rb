require 'yaml'

module Chart
  class Theme
    class ThemeNotFound < RuntimeError; end
    
    THEME_FILES = ["#{File.dirname(__FILE__)}/../themes.yml"]

    attr_accessor :colors
    attr_accessor :bar_colors
    attr_accessor :background
    attr_accessor :chart_background
    
    def self.load(theme_name)
      theme = new(theme_name)
    end
    
    # Allows you to specify paths for custome theme files in YAML format
    def self.add_theme_file(file)
      THEME_FILES << file
    end
    
    def initialize(theme_name)
      themes = {}
      THEME_FILES.each {|f| themes.update YAML::load(File.open(f))}
      theme = themes[theme_name]
      if theme
        self.colors = theme[:colors]
        self.bar_colors = theme[:bar_colors]
        self.background = theme[:background]
        self.chart_background = theme[:chart_background]
        self
      else
        raise(ThemeNotFound, "Could not locate #{theme_name} theme ...")
      end
    end
    
    def to_options
      {:background => background, :chart_background=>chart_background, :bar_colors => bar_colors.join(',')}
    end
  end
end