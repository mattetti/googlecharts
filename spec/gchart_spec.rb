require File.dirname(__FILE__) + '/spec_helper.rb'
require File.dirname(__FILE__) + '/../lib/gchart'

Chart::Theme.add_theme_file("#{File.dirname(__FILE__)}/fixtures/test_theme.yml")

# Time to add your specs!
# http://rspec.rubyforge.org/
describe "The Gchart class" do
  it "should show supported_types on error" do
    Gchart.supported_types.should match(/line/)
  end

  it "should return supported types" do
    Gchart.types.include?('line').should be_true
  end
end

describe "generating a default Gchart" do

  before(:each) do
    @chart = Gchart.line
  end

  it "should include the Google URL" do
    @chart.include?("http://chart.apis.google.com/chart?").should be_true
  end

  it "should have a default size" do
    @chart.should include('chs=300x200')
  end

  it "should be able to have a custom size" do
    Gchart.line(:size => '400x600').include?('chs=400x600').should be_true
    Gchart.line(:width => 400, :height => 600).include?('chs=400x600').should be_true
  end

  it "should have query parameters in predictable order" do
    Gchart.line(:axis_with_labels => 'x,y,r', :size => '400x600').should match(/chxt=.+cht=.+chs=/)
  end

  it "should have a type" do
    @chart.include?('cht=lc').should be_true
  end

  it 'should use theme defaults if theme is set' do
    Gchart.line(:theme=>:test).should include('chco=6886B4,FDD84E')
    if RUBY_VERSION.to_f < 1.9
      Gchart.line(:theme=>:test).should include(Gchart.jstize('chf=c,s,FFFFFF|bg,s,FFFFFF')) 
    else
       Gchart.line(:theme=>:test).should include(Gchart.jstize('chf=bg,s,FFFFFF|c,s,FFFFFF'))
    end
  end

  it "should use the simple encoding by default with auto max value" do
    # 9 is the max value in simple encoding, 26 being our max value the 2nd encoded value should be 9
    Gchart.line(:data => [0, 26]).should include('chd=s:A9')
    Gchart.line(:data => [0, 26], :max_value => 26, :axis_with_labels => 'y').should include('chxr=0,0,26')
  end

  it "should support simple encoding with and without max_value" do
    Gchart.line(:data => [0, 26], :max_value => 26).should include('chd=s:A9')
    Gchart.line(:data => [0, 26], :max_value => false).should include('chd=s:Aa')
  end

  it "should support the extended encoding and encode properly" do
    Gchart.line(:data => [0, 10], :encoding => 'extended', :max_value => false).include?('chd=e:AA').should be_true
    Gchart.line(:encoding => 'extended',
                :max_value => false,
                :data => [[0,25,26,51,52,61,62,63], [64,89,90,115,4084]]
                ).include?('chd=e:AAAZAaAzA0A9A-A.,BABZBaBz.0').should be_true
  end

  it "should auto set the max value for extended encoding" do
    Gchart.line(:data => [0, 25], :encoding => 'extended', :max_value => false).should include('chd=e:AAAZ')
    # Extended encoding max value is '..'
    Gchart.line(:data => [0, 25], :encoding => 'extended').include?('chd=e:AA..').should be_true
  end

  it "should be able to have data with text encoding" do
    Gchart.line(:data => [10, 5.2, 4, 45, 78], :encoding => 'text').should include('chd=t:10,5.2,4,45,78')
  end

  it "should be able to have missing data points with text encoding" do
    Gchart.line(:data => [10, 5.2, nil, 45, 78], :encoding => 'text').should include('chd=t:10,5.2,_,45,78')
  end

  it "should handle max and min values with text encoding" do
    Gchart.line(:data => [10, 5.2, 4, 45, 78], :encoding => 'text').should include('chds=0,78')
  end

  it "should automatically handle negative values with proper max/min limits when using text encoding" do
    Gchart.line(:data => [-10, 5.2, 4, 45, 78], :encoding => 'text').should include('chds=-10,78')
  end

  it "should handle negative values with manual max/min limits when using text encoding" do
   Gchart.line(:data => [-10, 5.2, 4, 45, 78], :encoding => 'text', :min_value => -20, :max_value => 100).include?('chds=-20,100').should be_true
  end

  it "should set the proper axis values when using text encoding and negative values" do
    Gchart.bar( :data       => [[-10], [100]],
                :encoding   => 'text',
                :horizontal => true,
                :min_value  => -20,
                :max_value  => 100,
                :axis_with_labels => 'x',
                :bar_colors => ['FD9A3B', '4BC7DC']).should include("chxr=0,-20,100")
  end

  it "should be able to have multiple set of data with text encoding" do
    Gchart.line(:data => [[10, 5.2, 4, 45, 78], [20, 40, 70, 15, 99]], :encoding => 'text').include?(Gchart.jstize('chd=t:10,5.2,4,45,78|20,40,70,15,99')).should be_true
  end

  it "should be able to receive a custom param" do
    Gchart.line(:custom => 'ceci_est_une_pipe').include?('ceci_est_une_pipe').should be_true
  end

  it "should be able to set label axis" do
    Gchart.line(:axis_with_labels => 'x,y,r').include?('chxt=x,y,r').should be_true
    Gchart.line(:axis_with_labels => ['x','y','r']).include?('chxt=x,y,r').should be_true
  end

  it "should be able to have axis labels" do
   Gchart.line(:axis_labels => ['Jan|July|Jan|July|Jan', '0|100', 'A|B|C', '2005|2006|2007']).include?(Gchart.jstize('chxl=0:|Jan|July|Jan|July|Jan|1:|0|100|2:|A|B|C|3:|2005|2006|2007')).should be_true
   Gchart.line(:axis_labels => ['Jan|July|Jan|July|Jan']).include?(Gchart.jstize('chxl=0:|Jan|July|Jan|July|Jan')).should be_true
   Gchart.line(:axis_labels => [['Jan','July','Jan','July','Jan']]).include?(Gchart.jstize('chxl=0:|Jan|July|Jan|July|Jan')).should be_true
   Gchart.line(:axis_labels => [['Jan','July','Jan','July','Jan'], ['0','100'], ['A','B','C'], ['2005','2006','2007']]).include?(Gchart.jstize('chxl=0:|Jan|July|Jan|July|Jan|1:|0|100|2:|A|B|C|3:|2005|2006|2007')).should be_true
  end
  
  def labeled_line(options = {})
    Gchart.line({:data => @data, :axis_with_labels => 'x,y'}.merge(options))
  end

  it "should display ranges properly" do
    @data = [85,107,123,131,155,172,173,189,203,222,217,233,250,239,256,267,247,261,275,295,288,305,322,307,325,347,331,346,363,382,343,359,383,352,374,393,358,379,396,416,377,398,419,380,409,426,453,432,452,465,436,460,480,440,457,474,501,457,489,507,347,373,413,402,424,448,475,488,513,475,507,530,440,476,500,518,481,512,531,367,396,423,387,415,446,478,442,469,492,463,489,508,463,491,518,549,503,526,547,493,530,549,493,520,541,564,510,535,564,492,512,537,502,530,548,491,514,538,568,524,548,568,512,533,552,577,520,545,570,516,536,555,514,536,566,521,553,579,604,541,569,595,551,581,602,549,576,606,631,589,615,650,597,624,646,672,605,626,654,584,608,631,574,597,622,559,591,614,644,580,603,629,584,615,631,558,591,618,641,314,356,395,397,429,450,421,454,477,507,458,490,560,593]
    labeled_line(:axis_labels => [((1..24).to_a << 1)]).
      should include('chxr=0,85,672')
  end
  
  def labeled_bar(options = {})
    Gchart.bar({:data => @data,
            :axis_with_labels => 'x,y',
            :axis_labels => [(1..12).to_a],
            :encoding => "text"
    }.merge(options))
  end

  it "should force the y range properly" do
    @data = [1,1,1,1,1,1,1,1,6,2,1,1]
    labeled_bar(
      :axis_range => [[0,0],[0,16]]
    ).should include('chxr=0,0,0|1,0,16')
    labeled_bar(
      :max_value => 16,
      :axis_range => [[0,0],[0,16]]
    ).should include('chxr=0,0,16|1,0,16')

    # nil means ignore axis
    labeled_bar(
      :axis_range => [nil,[0,16]]
    ).should include('chxr=1,0,16')

    # empty array means take defaults
    labeled_bar(
      :max_value => 16,
      :axis_range => [[],[0,16]]
    ).should include('chxr=0,0,16|1,0,16')
    labeled_bar(
      :axis_range => [[],[0,16]]
    ).should include('chxr=0,0|1,0,16')

    Gchart.line(
            :data => [0,20, 40, 60, 140, 230, 60],
            :axis_with_labels => 'y').should include("chxr=0,0,230")
  end
  
  it "should take in consideration the max value when creating a range" do
    data = [85,107,123,131,155,172,173,189,203,222,217,233,250,239,256,267,247,261,275,295,288,305,322,307,325,347,331,346,363,382,343,359,383,352,374,393,358,379,396,416,377,398,419,380,409,426,453,432,452,465,436,460,480,440,457,474,501,457,489,507,347,373,413,402,424,448,475,488,513,475,507,530,440,476,500,518,481,512,531,367,396,423,387,415,446,478,442,469,492,463,489,508,463,491,518,549,503,526,547,493,530,549,493,520,541,564,510,535,564,492,512,537,502,530,548,491,514,538,568,524,548,568,512,533,552,577,520,545,570,516,536,555,514,536,566,521,553,579,604,541,569,595,551,581,602,549,576,606,631,589,615,650,597,624,646,672,605,626,654,584,608,631,574,597,622,559,591,614,644,580,603,629,584,615,631,558,591,618,641,314,356,395,397,429,450,421,454,477,507,458,490,560,593]
    url = Gchart.line(:data => data, :axis_with_labels => 'x,y', :axis_labels => [((1..24).to_a << 1)], :max_value => 700)
    url.should include('chxr=0,85,700')
  end
  
  it 'should generate different labels and legend' do
    Gchart.pie(:legend => %w(1 2 3), :labels=>%w(one two three)).should(include('chdl=1|2|3') && include('chl=one|two|three'))
  end

end

describe "generating different type of charts" do

  it "should be able to generate a line chart" do
    Gchart.line.should be_an_instance_of(String)
    Gchart.line.include?('cht=lc').should be_true
  end

  it "should be able to generate a sparkline chart" do
    Gchart.sparkline.should be_an_instance_of(String)
    Gchart.sparkline.include?('cht=ls').should be_true
  end

  it "should be able to generate a line xy chart" do
    Gchart.line_xy.should be_an_instance_of(String)
    Gchart.line_xy.include?('cht=lxy').should be_true
  end

  it "should be able to generate a scatter chart" do
    Gchart.scatter.should be_an_instance_of(String)
    Gchart.scatter.include?('cht=s').should be_true
  end

  it "should be able to generate a bar chart" do
    Gchart.bar.should be_an_instance_of(String)
    Gchart.bar.include?('cht=bvs').should be_true
  end

  it "should be able to generate a Venn diagram" do
    Gchart.venn.should be_an_instance_of(String)
    Gchart.venn.include?('cht=v').should be_true
  end

  it "should be able to generate a Pie Chart" do
    Gchart.pie.should be_an_instance_of(String)
    Gchart.pie.include?('cht=p').should be_true
  end

  it "should be able to generate a Google-O-Meter" do
    Gchart.meter.should be_an_instance_of(String)
    Gchart.meter.include?('cht=gom').should be_true
  end

  it "should be able to generate a map chart" do
    Gchart.map.should be_an_instance_of(String)
    Gchart.map.include?('cht=t').should be_true
  end

  it "should not support other types" do
    msg = "sexy is not a supported chart format. Please use one of the following: #{Gchart.supported_types}."
    lambda{Gchart.sexy}.should raise_error(NoMethodError)
  end

end


describe "range markers" do

  it "should be able to generate given a hash of range-marker options" do
    Gchart.line(:range_markers => {:start_position => 0.59, :stop_position => 0.61, :color => 'ff0000'}).include?('chm=r,ff0000,0,0.59,0.61').should be_true
  end

  it "should be able to generate given an array of range-marker hash options" do
    Gchart.line(:range_markers => [
          {:start_position => 0.59, :stop_position => 0.61, :color => 'ff0000'},
          {:start_position => 0, :stop_position => 0.6, :color => '666666'},
          {:color => 'cccccc', :start_position => 0.6, :stop_position => 1}
        ]).include?(Gchart.jstize('r,ff0000,0,0.59,0.61|r,666666,0,0,0.6|r,cccccc,0,0.6,1')).should be_true
  end

  it "should allow a :overlaid? to be set" do
    Gchart.line(:range_markers => {:start_position => 0.59, :stop_position => 0.61, :color => 'ffffff', :overlaid? => true}).include?('chm=r,ffffff,0,0.59,0.61,1').should be_true
    Gchart.line(:range_markers => {:start_position => 0.59, :stop_position => 0.61, :color => 'ffffff', :overlaid? => false}).include?('chm=r,ffffff,0,0.59,0.61').should be_true
  end

  describe "when setting the orientation option" do
    before(:each) do
      @options = {:start_position => 0.59, :stop_position => 0.61, :color => 'ff0000'}
    end

    it "to vertical (R) if given a valid option" do
      Gchart.line(:range_markers => @options.merge(:orientation => 'v')).include?('chm=R').should be_true
      Gchart.line(:range_markers => @options.merge(:orientation => 'V')).include?('chm=R').should be_true
      Gchart.line(:range_markers => @options.merge(:orientation => 'R')).include?('chm=R').should be_true
      Gchart.line(:range_markers => @options.merge(:orientation => 'vertical')).include?('chm=R').should be_true
      Gchart.line(:range_markers => @options.merge(:orientation => 'Vertical')).include?('chm=R').should be_true
    end

    it "to horizontal (r) if given a valid option (actually anything other than the vertical options)" do
      Gchart.line(:range_markers => @options.merge(:orientation => 'horizontal')).include?('chm=r').should be_true
      Gchart.line(:range_markers => @options.merge(:orientation => 'h')).include?('chm=r').should be_true
      Gchart.line(:range_markers => @options.merge(:orientation => 'etc')).include?('chm=r').should be_true
    end

    it "if left blank defaults to horizontal (r)" do
      Gchart.line(:range_markers => @options).include?('chm=r').should be_true
    end
  end

end


describe "a bar graph" do

  it "should have a default vertical orientation" do
    Gchart.bar.include?('cht=bvs').should be_true
  end

  it "should be able to have a different orientation" do
    Gchart.bar(:orientation => 'vertical').include?('cht=bvs').should be_true
    Gchart.bar(:orientation => 'v').include?('cht=bvs').should be_true
    Gchart.bar(:orientation => 'h').include?('cht=bhs').should be_true
    Gchart.bar(:orientation => 'horizontal').include?('cht=bhs').should be_true
    Gchart.bar(:horizontal => false).include?('cht=bvs').should be_true
  end

  it "should be set to be stacked by default" do
    Gchart.bar.include?('cht=bvs').should be_true
  end

  it "should be able to stacked or grouped" do
    Gchart.bar(:stacked => true).include?('cht=bvs').should be_true
    Gchart.bar(:stacked => false).include?('cht=bvg').should be_true
    Gchart.bar(:grouped => true).include?('cht=bvg').should be_true
    Gchart.bar(:grouped => false).include?('cht=bvs').should be_true
  end

  it "should be able to have different bar colors" do
    Gchart.bar(:bar_colors => 'efefef,00ffff').include?('chco=').should be_true
    Gchart.bar(:bar_colors => 'efefef,00ffff').include?('chco=efefef,00ffff').should be_true
    # alias
    Gchart.bar(:bar_color => 'efefef').include?('chco=efefef').should be_true
  end

  it "should be able to have different bar colors when using an array of colors" do
    Gchart.bar(:bar_colors => ['efefef','00ffff']).include?('chco=efefef,00ffff').should be_true
  end

  it 'should be able to accept a string of width and spacing options' do
    Gchart.bar(:bar_width_and_spacing => '25,6').include?('chbh=25,6').should be_true
  end

  it 'should be able to accept a single fixnum width and spacing option to set the bar width' do
    Gchart.bar(:bar_width_and_spacing => 25).include?('chbh=25').should be_true
  end

  it 'should be able to accept an array of width and spacing options' do
    Gchart.bar(:bar_width_and_spacing => [25,6,12]).include?('chbh=25,6,12').should be_true
    Gchart.bar(:bar_width_and_spacing => [25,6]).include?('chbh=25,6').should be_true
    Gchart.bar(:bar_width_and_spacing => [25]).include?('chbh=25').should be_true
  end

  describe "with a hash of width and spacing options" do

    before(:each) do
      @default_width         = 23
      @default_spacing       = 4
      @default_group_spacing = 8
    end

    it 'should be able to have a custom bar width' do
      Gchart.bar(:bar_width_and_spacing => {:width => 19}).include?("chbh=19,#{@default_spacing},#{@default_group_spacing}").should be_true
    end

    it 'should be able to have custom spacing' do
      Gchart.bar(:bar_width_and_spacing => {:spacing => 19}).include?("chbh=#{@default_width},19,#{@default_group_spacing}").should be_true
    end

    it 'should be able to have custom group spacing' do
      Gchart.bar(:bar_width_and_spacing => {:group_spacing => 19}).include?("chbh=#{@default_width},#{@default_spacing},19").should be_true
    end

  end

end

describe "a line chart" do

  before(:each) do
    @title = 'Chart Title'
    @legend = ['first data set label', 'n data set label']
    @chart = Gchart.line(:title => @title, :legend => @legend)
  end

  it 'should be able have a chart title' do
    @chart.include?("chtt=Chart+Title").should be_true
  end

  it "should be able to a custom color, size and alignment for title" do
     Gchart.line(:title => @title, :title_color => 'FF0000').include?('chts=FF0000').should be_true
     Gchart.line(:title => @title, :title_size => '20').include?('chts=454545,20').should be_true
     Gchart.line(:title => @title, :title_size => '20', :title_alignment => :left).include?('chts=454545,20,l').should be_true
  end

  it "should be able to have multiple legends" do
    @chart.include?(Gchart.jstize("chdl=first+data+set+label|n+data+set+label")).should be_true
  end

  it "should escape text values in url" do
    title = 'Chart & Title'
    legend = ['first data & set label', 'n data set label']
    chart = Gchart.line(:title => title, :legend => legend)
    chart.include?(Gchart.jstize("chdl=first+data+%26+set+label|n+data+set+label")).should be_true
  end

  it "should be able to have one legend" do
    chart = Gchart.line(:legend => 'legend label')
    chart.include?("chdl=legend+label").should be_true
  end
  
  it "should be able to set the position of the legend" do
    title = 'Chart & Title'
    legend = ['first data & set label', 'n data set label']
    
    chart = Gchart.line(:title => title, :legend => legend, :legend_position => :bottom_vertical)
    chart.include?("chdlp=bv").should be_true
    
    chart = Gchart.line(:title => title, :legend => legend, :legend_position => 'r')
    chart.include?("chdlp=r").should be_true
  end

  it "should be able to set the background fill" do
    Gchart.line(:bg => 'efefef').should include("chf=bg,s,efefef")
    Gchart.line(:bg => {:color => 'efefef', :type => 'solid'}).should include("chf=bg,s,efefef")

    Gchart.line(:bg => {:color => 'efefef', :type => 'gradient'}).should include("chf=bg,lg,0,efefef,0,ffffff,1")
    Gchart.line(:bg => {:color => 'efefef,0,ffffff,1', :type => 'gradient'}).should include("chf=bg,lg,0,efefef,0,ffffff,1")
    Gchart.line(:bg => {:color => 'efefef', :type => 'gradient', :angle => 90}).should include("chf=bg,lg,90,efefef,0,ffffff,1")

    Gchart.line(:bg => {:color => 'efefef', :type => 'stripes'}).should include("chf=bg,ls,90,efefef,0.2,ffffff,0.2")
  end

  it "should be able to set a graph fill" do
    Gchart.line(:graph_bg => 'efefef').should include("chf=c,s,efefef")
    Gchart.line(:graph_bg => {:color => 'efefef', :type => 'solid'}).include?("chf=c,s,efefef").should be_true
    Gchart.line(:graph_bg => {:color => 'efefef', :type => 'gradient'}).include?("chf=c,lg,0,efefef,0,ffffff,1").should be_true
    Gchart.line(:graph_bg => {:color => 'efefef,0,ffffff,1', :type => 'gradient'}).include?("chf=c,lg,0,efefef,0,ffffff,1").should be_true
    Gchart.line(:graph_bg => {:color => 'efefef', :type => 'gradient', :angle => 90}).include?("chf=c,lg,90,efefef,0,ffffff,1").should be_true
  end

  it "should be able to set both a graph and a background fill" do
    Gchart.line(:bg => 'efefef', :graph_bg => '76A4FB').include?("bg,s,efefef").should be_true
    Gchart.line(:bg => 'efefef', :graph_bg => '76A4FB').include?("c,s,76A4FB").should be_true
    if RUBY_VERSION.to_f < 1.9
      Gchart.line(:bg => 'efefef', :graph_bg => '76A4FB').include?(Gchart.jstize("chf=c,s,76A4FB|bg,s,efefef")).should be_true      
    else
      Gchart.line(:bg => 'efefef', :graph_bg => '76A4FB').include?(Gchart.jstize("chf=bg,s,efefef|c,s,76A4FB")).should be_true
    end
  end

  it "should be able to have different line colors" do
    Gchart.line(:line_colors => 'efefef|00ffff').include?(Gchart.jstize('chco=efefef|00ffff')).should be_true
    Gchart.line(:line_color => 'efefef|00ffff').include?(Gchart.jstize('chco=efefef|00ffff')).should be_true
  end

  it "should be able to render a graph where all the data values are 0" do
    Gchart.line(:data => [0, 0, 0]).should include("chd=s:AAA")
  end

end

describe "a sparkline chart" do

  before(:each) do
    @title = 'Chart Title'
    @legend = ['first data set label', 'n data set label']
    @jstized_legend = Gchart.jstize(@legend.join('|'))
    @data = [27,25,25,25,25,27,100,31,25,36,25,25,39,25,31,25,25,25,26,26,25,25,28,25,25,100,28,27,31,25,27,27,29,25,27,26,26,25,26,26,35,33,34,25,26,25,36,25,26,37,33,33,37,37,39,25,25,25,25]
    @chart = Gchart.sparkline(:title => @title, :data => @data, :legend => @legend)
  end

  it "should create a sparkline" do
    @chart.include?('cht=ls').should be_true
  end

  it 'should be able have a chart title' do
    @chart.include?("chtt=Chart+Title").should be_true
  end

  it "should be able to a custom color and size title" do
     Gchart.sparkline(:title => @title, :title_color => 'FF0000').include?('chts=FF0000').should be_true
     Gchart.sparkline(:title => @title, :title_size => '20').include?('chts=454545,20').should be_true
  end

  it "should be able to have multiple legends" do
    @chart.include?(Gchart.jstize("chdl=first+data+set+label|n+data+set+label")).should be_true
  end

  it "should be able to have one legend" do
    chart = Gchart.sparkline(:legend => 'legend label')
    chart.include?("chdl=legend+label").should be_true
  end

  it "should be able to set the background fill" do
    Gchart.sparkline(:bg => 'efefef').include?("chf=bg,s,efefef").should be_true
    Gchart.sparkline(:bg => {:color => 'efefef', :type => 'solid'}).include?("chf=bg,s,efefef").should be_true

    Gchart.sparkline(:bg => {:color => 'efefef', :type => 'gradient'}).include?("chf=bg,lg,0,efefef,0,ffffff,1").should be_true
    Gchart.sparkline(:bg => {:color => 'efefef,0,ffffff,1', :type => 'gradient'}).include?("chf=bg,lg,0,efefef,0,ffffff,1").should be_true
    Gchart.sparkline(:bg => {:color => 'efefef', :type => 'gradient', :angle => 90}).include?("chf=bg,lg,90,efefef,0,ffffff,1").should be_true

    Gchart.sparkline(:bg => {:color => 'efefef', :type => 'stripes'}).include?("chf=bg,ls,90,efefef,0.2,ffffff,0.2").should be_true
  end

  it "should be able to set a graph fill" do
    Gchart.sparkline(:graph_bg => 'efefef').include?("chf=c,s,efefef").should be_true
    Gchart.sparkline(:graph_bg => {:color => 'efefef', :type => 'solid'}).include?("chf=c,s,efefef").should be_true
    Gchart.sparkline(:graph_bg => {:color => 'efefef', :type => 'gradient'}).include?("chf=c,lg,0,efefef,0,ffffff,1").should be_true
    Gchart.sparkline(:graph_bg => {:color => 'efefef,0,ffffff,1', :type => 'gradient'}).include?("chf=c,lg,0,efefef,0,ffffff,1").should be_true
    Gchart.sparkline(:graph_bg => {:color => 'efefef', :type => 'gradient', :angle => 90}).include?("chf=c,lg,90,efefef,0,ffffff,1").should be_true
  end

  it "should be able to set both a graph and a background fill" do
    Gchart.sparkline(:bg => 'efefef', :graph_bg => '76A4FB').include?("bg,s,efefef").should be_true
    Gchart.sparkline(:bg => 'efefef', :graph_bg => '76A4FB').include?("c,s,76A4FB").should be_true
    if RUBY_VERSION.to_f < 1.9
      Gchart.sparkline(:bg => 'efefef', :graph_bg => '76A4FB').include?(Gchart.jstize("chf=c,s,76A4FB|bg,s,efefef")).should be_true
    else
      Gchart.sparkline(:bg => 'efefef', :graph_bg => '76A4FB').include?(Gchart.jstize("chf=bg,s,efefef|c,s,76A4FB")).should be_true
    end
  end

  it "should be able to have different line colors" do
    Gchart.sparkline(:line_colors => 'efefef|00ffff').include?(Gchart.jstize('chco=efefef|00ffff')).should be_true
    Gchart.sparkline(:line_color => 'efefef|00ffff').include?(Gchart.jstize('chco=efefef|00ffff')).should be_true
  end

end

describe "a 3d pie chart" do

  before(:each) do
    @title = 'Chart Title'
    @legend = ['first data set label', 'n data set label']
    @jstized_legend = Gchart.jstize(@legend.join('|'))
    @data = [12,8,40,15,5]
    @chart = Gchart.pie(:title => @title, :legend => @legend, :data => @data)
  end

  it "should create a pie" do
    @chart.include?('cht=p').should be_true
  end

  it "should be able to be in 3d" do
    Gchart.pie_3d(:title => @title, :legend => @legend, :data => @data).include?('cht=p3').should be_true
  end

end

describe "a google-o-meter" do

  before(:each) do
    @data = [70]
    @legend = ['arrow points here']
    @jstized_legend = Gchart.jstize(@legend.join('|'))
    @chart = Gchart.meter(:data => @data)
  end

  it "should create a meter" do
    @chart.include?('cht=gom').should be_true
  end

  it "should be able to set a solid background fill" do
    Gchart.meter(:bg => 'efefef').include?("chf=bg,s,efefef").should be_true
    Gchart.meter(:bg => {:color => 'efefef', :type => 'solid'}).include?("chf=bg,s,efefef").should be_true
  end

  it "should be able to set labels by using the legend or labesl accessor" do
    Gchart.meter(:title => @title, :labels => @legend, :data => @data).should include("chl=#{@jstized_legend}")
    Gchart.meter(:title => @title, :labels => @legend, :data => @data).should == Gchart.meter(:title => @title, :legend => @legend, :data => @data)
  end

end

describe "a map chart" do

  before(:each) do
    @data = [0,100,50,32]
    @geographical_area = 'usa'
    @map_colors = ['FFFFFF', 'FF0000', 'FFFF00', '00FF00']
    @country_codes = ['MT', 'WY', "ID", 'SD']
    @chart = Gchart.map(:data => @data, :encoding => 'text', :size => '400x300',
      :geographical_area => @geographical_area, :map_colors => @map_colors,
      :country_codes => @country_codes)
  end

  it "should create a map" do
    @chart.include?('cht=t').should be_true
  end

  it "should set the geographical area" do
    @chart.include?('chtm=usa').should be_true
  end

  it "should set the map colors" do
    @chart.include?('chco=FFFFFF,FF0000,FFFF00,00FF00').should be_true
  end

  it "should set the country/state codes" do
    @chart.include?('chld=MTWYIDSD').should be_true
  end

  it "should set the chart data" do
    @chart.include?('chd=t:0,100,50,32').should be_true
  end

end

describe 'exporting a chart' do

  it "should be available in the url format by default" do
    Gchart.line(:data => [0, 26], :format => 'url').should == Gchart.line(:data => [0, 26])
  end

  it "should be available as an image tag" do
    Gchart.line(:data => [0, 26], :format => 'image_tag').should match(/<img src=(.*) width="300" height="200" alt="Google Chart" \/>/)
  end

  it "should be available as an image tag using img_tag alias" do
    Gchart.line(:data => [0, 26], :format => 'img_tag').should match(/<img src=(.*) width="300" height="200" alt="Google Chart" \/>/)
  end

  it "should be available as an image tag using custom dimensions" do
    Gchart.line(:data => [0, 26], :format => 'image_tag', :size => '400x400').should match(/<img src=(.*) width="400" height="400" alt="Google Chart" \/>/)
  end

  it "should be available as an image tag using custom alt text" do
    Gchart.line(:data => [0, 26], :format => 'image_tag', :alt => 'Sexy chart').should match(/<img src=(.*) width="300" height="200" alt="Sexy chart" \/>/)
  end

  it "should be available as an image tag using custom title text" do
    Gchart.line(:data => [0, 26], :format => 'image_tag', :title => 'Sexy chart').should match(/<img src=(.*) width="300" height="200" alt="Google Chart" title="Sexy chart" \/>/)
  end

  it "should be available as an image tag using custom css id selector" do
    Gchart.line(:data => [0, 26], :format => 'image_tag', :id => 'chart').should match(/<img id="chart" src=(.*) width="300" height="200" alt="Google Chart" \/>/)
  end

  it "should be available as an image tag using custom css class selector" do
    Gchart.line(:data => [0, 26], :format => 'image_tag', :class => 'chart').should match(/<img class="chart" src=(.*) width="300" height="200" alt="Google Chart" \/>/)
  end

  it "should use ampersands to separate key/value pairs in URLs by default" do
    Gchart.line(:data => [0, 26]).should satisfy {|chart| chart.include? "&" }
    Gchart.line(:data => [0, 26]).should_not satisfy {|chart| chart.include? "&amp;" }
  end

  it "should escape ampersands in URLs when used as an image tag" do
    Gchart.line(:data => [0, 26], :format => 'image_tag', :class => 'chart').should satisfy {|chart| chart.include? "&amp;" }
  end

  it "should be available as a file" do
    File.delete('chart.png') if File.exist?('chart.png')
    Gchart.line(:data => [0, 26], :format => 'file')
    File.exist?('chart.png').should be_true
    File.delete('chart.png') if File.exist?('chart.png')
  end

  it "should be available as a file using a custom file name" do
    File.delete('custom_file_name.png') if File.exist?('custom_file_name.png')
    Gchart.line(:data => [0, 26], :format => 'file', :filename => 'custom_file_name.png')
    File.exist?('custom_file_name.png').should be_true
    File.delete('custom_file_name.png') if File.exist?('custom_file_name.png')
  end

  it "should work even with multiple attrs" do
    File.delete('foo.png') if File.exist?('foo.png')
    Gchart.line(:size => '400x200',
                :data => [1,2,3,4,5],
                # :axis_labels => [[1,2,3,4, 5], %w[foo bar]],
                :axis_with_labels => 'x,r',
                :format => "file",
                :filename => "foo.png"
                )
    File.exist?('foo.png').should be_true
    File.delete('foo.png') if File.exist?('foo.png')
  end

end

describe 'SSL support' do
  it 'should change url if is presented' do
    Gchart.line(:use_ssl => true).should include('https://chart.googleapis.com/chart?')
  end
  
  it "should be available as a file" do
    File.delete('chart.png') if File.exist?('chart.png')
    Gchart.line(:data => [0, 26], :format => 'file', :use_ssl => true)
    File.exist?('chart.png').should be_true
    File.delete('chart.png') if File.exist?('chart.png')
  end
end
