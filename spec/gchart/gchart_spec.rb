require 'spec_helper.rb'

Gchart::Theme.add_theme_file('spec/fixtures/test_theme.yml')

describe "The Gchart class" do
  it "should show supported_types on error" do
    Gchart::Gchart.supported_types.should match(/line/)
  end

  it "should return supported types" do
    Gchart::Gchart.types.should include('line')
  end

  it "should support theme option" do
    chart = Gchart::Line.new(:type => 'line',:theme => :test)
    chart.draw.should include('chco=6886B4,FDD84E')
  end
end

describe "generating a default Gchart" do

  before(:each) do
    @chart = Gchart::Line.new.draw
  end

  it "should include the Google URL" do
    @chart.should include("http://chart.apis.google.com/chart?")
  end

  it "should have a default size" do
    @chart.should include('chs=300x200')
  end

  it "should have a type" do
    @chart.should include('cht=lc')
  end

  it 'should use theme defaults if theme is set' do
    #Gchart::Gchart.new(:theme=>:test).should include('chco=6886B4,FDD84E')
    #Gchart::Gchart.new(:theme=>:test).should match(/chf=(c,s,FFFFFF\|bg,s,FFFFFF|bg,s,FFFFFF\|c,s,FFFFFF)/)
  end

  it "should use the simple encoding by default with auto max value" do
    # 9 is the max value in simple encoding, 26 being our max value the 2nd encoded value should be 9
    Gchart::Line.new(:data => [0, 26]).draw.should include('chd=s:A9')
    Gchart::Line.new(:data => [0, 26], :max_value => 26, :axis_with_labels => 'y').draw.should include('chxr=0,0,26')
  end

  it "should support simple encoding with and without max_value" do
    Gchart::Line.new(:data => [0, 26], :max_value => 26).draw.should include('chd=s:A9')
    Gchart::Line.new(:data => [0, 26], :max_value => false).draw.should include('chd=s:Aa')
  end

  it "should support the extended encoding and encode properly" do
    Gchart::Line.new(:data => [0, 10], :encoding => 'extended', :max_value => false).draw.should include('chd=e:AA')
    Gchart::Line.new(:encoding => 'extended',
                :max_value => false,
                :data => [[0,25,26,51,52,61,62,63], [64,89,90,115,4084]]
                ).draw.should include('chd=e:AAAZAaAzA0A9A-A.,BABZBaBz.0')
  end

  it "should auto set the max value for extended encoding" do
    Gchart::Line.new(:data => [0, 25], :encoding => 'extended', :max_value => false).draw.should include('chd=e:AAAZ')
    # Extended encoding max value is '..'
    Gchart::Line.new(:data => [0, 25], :encoding => 'extended').draw.should include('chd=e:AA..')
  end

  it "should be able to have data with text encoding" do
    Gchart::Line.new(:data => [10, 5.2, 4, 45, 78], :encoding => 'text').draw.should include('chd=t:10,5.2,4,45,78')
  end

  it "should be able to have missing data points with text encoding" do
    Gchart::Line.new(:data => [10, 5.2, nil, 45, 78], :encoding => 'text').draw.should include('chd=t:10,5.2,_,45,78')
  end

  it "should handle max and min values with text encoding" do
    Gchart::Line.new(:data => [10, 5.2, 4, 45, 78], :encoding => 'text').draw.should include('chds=0,78')
  end

  it "should automatically handle negative values with proper max/min limits when using text encoding" do
    Gchart::Line.new(:data => [-10, 5.2, 4, 45, 78], :encoding => 'text').draw.should include('chds=-10,78')
  end

  it "should handle negative values with manual max/min limits when using text encoding" do
   Gchart::Line.new(:data => [-10, 5.2, 4, 45, 78], :encoding => 'text', :min_value => -20, :max_value => 100).draw.should include('chds=-20,100')
  end

  it "should set the proper axis values when using text encoding and negative values" do
    Gchart::Bar.new( :data       => [[-10], [100]],
                :encoding   => 'text',
                :horizontal => true,
                :min_value  => -20,
                :max_value  => 100,
                :axis_with_labels => 'x',
                :bar_colors => ['FD9A3B', '4BC7DC']).draw.should include("chxr=0,-20,100")
  end

  it "should be able to have multiple set of data with text encoding" do
    Gchart::Line.new(:data => [[10, 5.2, 4, 45, 78], [20, 40, 70, 15, 99]], :encoding => 'text').draw.should include(Gchart::Gchart.jstize('chd=t:10,5.2,4,45,78|20,40,70,15,99'))
  end

  it "should be able to have axis labels" do
   Gchart::Line.new(:axis_labels => ['Jan|July|Jan|July|Jan', '0|100', 'A|B|C', '2005|2006|2007']).draw.should include(Gchart::Gchart.jstize('chxl=0:|Jan|July|Jan|July|Jan|1:|0|100|2:|A|B|C|3:|2005|2006|2007'))
   Gchart::Line.new(:axis_labels => ['Jan|July|Jan|July|Jan']).draw.should include(Gchart::Gchart.jstize('chxl=0:|Jan|July|Jan|July|Jan'))
   Gchart::Line.new(:axis_labels => [['Jan','July','Jan','July','Jan']]).draw.should include(Gchart::Gchart.jstize('chxl=0:|Jan|July|Jan|July|Jan'))
   Gchart::Line.new(:axis_labels => [['Jan','July','Jan','July','Jan'], ['0','100'], ['A','B','C'], ['2005','2006','2007']]).draw.should include(Gchart::Gchart.jstize('chxl=0:|Jan|July|Jan|July|Jan|1:|0|100|2:|A|B|C|3:|2005|2006|2007'))
  end

  def labeled_line(options = {})
    Gchart::Line.new({:data => @data, :axis_with_labels => 'x,y'}.merge(options)).draw
  end

  it "should display ranges properly" do
    @data = [85,107,123,131,155,172,173,189,203,222,217,233,250,239,256,267,247,261,275,295,288,305,322,307,325,347,331,346,363,382,343,359,383,352,374,393,358,379,396,416,377,398,419,380,409,426,453,432,452,465,436,460,480,440,457,474,501,457,489,507,347,373,413,402,424,448,475,488,513,475,507,530,440,476,500,518,481,512,531,367,396,423,387,415,446,478,442,469,492,463,489,508,463,491,518,549,503,526,547,493,530,549,493,520,541,564,510,535,564,492,512,537,502,530,548,491,514,538,568,524,548,568,512,533,552,577,520,545,570,516,536,555,514,536,566,521,553,579,604,541,569,595,551,581,602,549,576,606,631,589,615,650,597,624,646,672,605,626,654,584,608,631,574,597,622,559,591,614,644,580,603,629,584,615,631,558,591,618,641,314,356,395,397,429,450,421,454,477,507,458,490,560,593]
    labeled_line(:axis_labels => [((1..24).to_a << 1)]).
      should include('chxr=0,85,672')
  end

  def labeled_bar(options = {})
    Gchart::Bar.new({:data => @data,
            :axis_with_labels => 'x,y',
            :axis_labels => [(1..12).to_a],
            :encoding => "text"
    }.merge(options)).draw
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

    Gchart::Line.new(
            :data => [0,20, 40, 60, 140, 230, 60],
            :axis_with_labels => 'y').draw.should include("chxr=0,0,230")
  end

  it "should take in consideration the max value when creating a range" do
    data = [85,107,123,131,155,172,173,189,203,222,217,233,250,239,256,267,247,261,275,295,288,305,322,307,325,347,331,346,363,382,343,359,383,352,374,393,358,379,396,416,377,398,419,380,409,426,453,432,452,465,436,460,480,440,457,474,501,457,489,507,347,373,413,402,424,448,475,488,513,475,507,530,440,476,500,518,481,512,531,367,396,423,387,415,446,478,442,469,492,463,489,508,463,491,518,549,503,526,547,493,530,549,493,520,541,564,510,535,564,492,512,537,502,530,548,491,514,538,568,524,548,568,512,533,552,577,520,545,570,516,536,555,514,536,566,521,553,579,604,541,569,595,551,581,602,549,576,606,631,589,615,650,597,624,646,672,605,626,654,584,608,631,574,597,622,559,591,614,644,580,603,629,584,615,631,558,591,618,641,314,356,395,397,429,450,421,454,477,507,458,490,560,593]
    url = Gchart::Line.new(:data => data, :axis_with_labels => 'x,y', :axis_labels => [((1..24).to_a << 1)], :max_value => 700).draw
    url.should include('chxr=0,85,700')
  end

  it 'should generate different labels and legend' do
    Gchart::Gchart.pie(:legend => %w(1 2 3), :labels=>%w(one two three)).should(include('chdl=1|2|3') && include('chl=one|two|three'))
  end
end

describe "generating different type of charts" do

  it "should be able to generate a line chart" do
    Gchart::Line.new.draw.should be_an_instance_of(String)
    Gchart::Line.new.draw.should include('cht=lc')
  end

  it "should be able to generate a sparkline chart" do
    Gchart::Gchart.sparkline.should be_an_instance_of(String)
    Gchart::Gchart.sparkline.should include('cht=ls')
  end

  it "should be able to generate a line xy chart" do
    Gchart::Gchart.line_xy.should be_an_instance_of(String)
    Gchart::Gchart.line_xy.should include('cht=lxy')
  end

  it "should be able to generate a scatter chart" do
    Gchart::Gchart.scatter.should be_an_instance_of(String)
    Gchart::Gchart.scatter.should include('cht=s')
  end

  it "should be able to generate a bar chart" do
    Gchart::Bar.new.draw.should be_an_instance_of(String)
    Gchart::Bar.new.draw.should include('cht=bvs')
  end

  it "should be able to generate a Venn diagram" do
    Gchart::Gchart.venn.should be_an_instance_of(String)
    Gchart::Gchart.venn.should include('cht=v')
  end

  it "should be able to generate a Pie Chart" do
    Gchart::Gchart.pie.should be_an_instance_of(String)
    Gchart::Gchart.pie.should include('cht=p')
  end

  it "should be able to generate a Google-O-Meter" do
    Gchart::Gchart.meter.should be_an_instance_of(String)
    Gchart::Gchart.meter.should include('cht=gom')
  end

  it "should be able to generate a map chart" do
    Gchart::Gchart.map.should be_an_instance_of(String)
    Gchart::Gchart.map.should include('cht=t')
  end

  it "should not support other types" do
    msg = "sexy is not a supported chart format. Please use one of the following: #{Gchart::Gchart.supported_types}."
    lambda{Gchart::Gchart.sexy}.should raise_error(NoMethodError)
  end
end


describe "range markers" do

  it "should be able to generate given a hash of range-marker options" do
    Gchart::Line.new(:range_markers => {:start_position => 0.59, :stop_position => 0.61, :color => 'ff0000'}).draw.should include('chm=r,ff0000,0,0.59,0.61')
  end

  it "should be able to generate given an array of range-marker hash options" do
    Gchart::Line.new(:range_markers => [
          {:start_position => 0.59, :stop_position => 0.61, :color => 'ff0000'},
          {:start_position => 0, :stop_position => 0.6, :color => '666666'},
          {:color => 'cccccc', :start_position => 0.6, :stop_position => 1}
        ]).draw.should include(Gchart::Gchart.jstize('r,ff0000,0,0.59,0.61|r,666666,0,0,0.6|r,cccccc,0,0.6,1'))
  end

  it "should allow a :overlaid? to be set" do
    Gchart::Line.new(:range_markers => {:start_position => 0.59, :stop_position => 0.61, :color => 'ffffff', :overlaid? => true}).draw.should include('chm=r,ffffff,0,0.59,0.61,1')
    Gchart::Line.new(:range_markers => {:start_position => 0.59, :stop_position => 0.61, :color => 'ffffff', :overlaid? => false}).draw.should include('chm=r,ffffff,0,0.59,0.61')
  end

  describe "when setting the orientation option" do
    before(:each) do
      @options = {:start_position => 0.59, :stop_position => 0.61, :color => 'ff0000'}
    end

    it "to vertical (R) if given a valid option" do
      Gchart::Line.new(:range_markers => @options.merge(:orientation => 'v')).draw.should include('chm=R')
      Gchart::Line.new(:range_markers => @options.merge(:orientation => 'V')).draw.should include('chm=R')
      Gchart::Line.new(:range_markers => @options.merge(:orientation => 'R')).draw.should include('chm=R')
      Gchart::Line.new(:range_markers => @options.merge(:orientation => 'vertical')).draw.should include('chm=R')
      Gchart::Line.new(:range_markers => @options.merge(:orientation => 'Vertical')).draw.should include('chm=R')
    end

    it "to horizontal (r) if given a valid option (actually anything other than the vertical options)" do
      Gchart::Line.new(:range_markers => @options.merge(:orientation => 'horizontal')).draw.should include('chm=r')
      Gchart::Line.new(:range_markers => @options.merge(:orientation => 'h')).draw.should include('chm=r')
      Gchart::Line.new(:range_markers => @options.merge(:orientation => 'etc')).draw.should include('chm=r')
    end

    it "if left blank defaults to horizontal (r)" do
      Gchart::Line.new(:range_markers => @options).draw.should include('chm=r')
    end
  end
end
describe "a line chart" do

  before(:each) do
    @title = 'Chart Title'
    @legend = ['first data set label', 'n data set label']
    @chart = Gchart::Line.new(:title => @title, :legend => @legend).draw
  end

  it 'should be able have a chart title' do
    @chart.should include("chtt=Chart+Title")
  end

  it "should be able to a custom color, size and alignment for title" do
     Gchart::Line.new(:title => @title, :title_color => 'FF0000').draw.should include('chts=FF0000')
     Gchart::Line.new(:title => @title, :title_size => '20').draw.should include('chts=454545,20')
     Gchart::Line.new(:title => @title, :title_size => '20', :title_alignment => :left).draw.should include('chts=454545,20,l')
  end

  it "should be able to have multiple legends" do
    @chart.should include(Gchart::Gchart.jstize("chdl=first+data+set+label|n+data+set+label"))
  end

  it "should escape text values in url" do
    title = 'Chart & Title'
    legend = ['first data & set label', 'n data set label']
    chart = Gchart::Line.new(:title => title, :legend => legend).draw
    chart.should include(Gchart::Gchart.jstize("chdl=first+data+%26+set+label|n+data+set+label"))
  end

  it "should be able to have one legend" do
    chart = Gchart::Line.new(:legend => 'legend label').draw
    chart.should include("chdl=legend+label")
  end

  it "should be able to set the position of the legend" do
    title = 'Chart & Title'
    legend = ['first data & set label', 'n data set label']

    chart = Gchart::Line.new(:title => title, :legend => legend, :legend_position => :bottom_vertical)
    chart.draw.should include("chdlp=bv")

    chart = Gchart::Line.new(:title => title, :legend => legend, :legend_position => 'r')
    chart.draw.should include("chdlp=r")
  end

  it "should be able to set the background fill" do
    Gchart::Line.new(:bg => 'efefef').draw.should include("chf=bg,s,efefef")
    Gchart::Line.new(:bg => {:color => 'efefef', :type => 'solid'}).draw.should include("chf=bg,s,efefef")

    Gchart::Line.new(:bg => {:color => 'efefef', :type => 'gradient'}).draw.should include("chf=bg,lg,0,efefef,0,ffffff,1")
    Gchart::Line.new(:bg => {:color => 'efefef,0,ffffff,1', :type => 'gradient'}).draw.should include("chf=bg,lg,0,efefef,0,ffffff,1")
    Gchart::Line.new(:bg => {:color => 'efefef', :type => 'gradient', :angle => 90}).draw.should include("chf=bg,lg,90,efefef,0,ffffff,1")

    Gchart::Line.new(:bg => {:color => 'efefef', :type => 'stripes'}).draw.should include("chf=bg,ls,90,efefef,0.2,ffffff,0.2")
  end

  it "should be able to set a graph fill" do
    Gchart::Line.new(:graph_bg => 'efefef').draw.should include("chf=c,s,efefef")
    Gchart::Line.new(:graph_bg => {:color => 'efefef', :type => 'solid'}).draw.should include("chf=c,s,efefef")
    Gchart::Line.new(:graph_bg => {:color => 'efefef', :type => 'gradient'}).draw.should include("chf=c,lg,0,efefef,0,ffffff,1")
    Gchart::Line.new(:graph_bg => {:color => 'efefef,0,ffffff,1', :type => 'gradient'}).draw.should include("chf=c,lg,0,efefef,0,ffffff,1")
    Gchart::Line.new(:graph_bg => {:color => 'efefef', :type => 'gradient', :angle => 90}).draw.should include("chf=c,lg,90,efefef,0,ffffff,1")
  end

  it "should be able to set both a graph and a background fill" do
    Gchart::Line.new(:bg => 'efefef', :graph_bg => '76A4FB').draw.should match /chf=(bg,s,efefef\|c,s,76A4FB|c,s,76A4FB\|bg,s,efefef)/
  end

  it "should be able to have different line colors" do
    Gchart::Line.new(:line_colors => 'efefef|00ffff').draw.should include(Gchart::Gchart.jstize('chco=efefef|00ffff'))
    Gchart::Line.new(:line_color => 'efefef|00ffff').draw.should include(Gchart::Gchart.jstize('chco=efefef|00ffff'))
  end

  it "should be able to render a graph where all the data values are 0" do
    Gchart::Line.new(:data => [0, 0, 0]).draw.should include("chd=s:AAA")
  end
end

describe "a sparkline chart" do

  before(:each) do
    @title = 'Chart Title'
    @legend = ['first data set label', 'n data set label']
    @jstized_legend = Gchart::Gchart.jstize(@legend.join('|'))
    @data = [27,25,25,25,25,27,100,31,25,36,25,25,39,25,31,25,25,25,26,26,25,25,28,25,25,100,28,27,31,25,27,27,29,25,27,26,26,25,26,26,35,33,34,25,26,25,36,25,26,37,33,33,37,37,39,25,25,25,25]
    @chart = Gchart::Gchart.sparkline(:title => @title, :data => @data, :legend => @legend)
  end

  it "should create a sparkline" do
    @chart.should include('cht=ls')
  end

  it 'should be able have a chart title' do
    @chart.should include("chtt=Chart+Title")
  end

  it "should be able to a custom color and size title" do
     Gchart::Gchart.sparkline(:title => @title, :title_color => 'FF0000').should include('chts=FF0000')
     Gchart::Gchart.sparkline(:title => @title, :title_size => '20').should include('chts=454545,20')
  end

  it "should be able to have multiple legends" do
    @chart.should include(Gchart::Gchart.jstize("chdl=first+data+set+label|n+data+set+label"))
  end

  it "should be able to have one legend" do
    chart = Gchart::Gchart.sparkline(:legend => 'legend label')
    chart.should include("chdl=legend+label")
  end

  it "should be able to set the background fill" do
    Gchart::Gchart.sparkline(:bg => 'efefef').should include("chf=bg,s,efefef")
    Gchart::Gchart.sparkline(:bg => {:color => 'efefef', :type => 'solid'}).should include("chf=bg,s,efefef")

    Gchart::Gchart.sparkline(:bg => {:color => 'efefef', :type => 'gradient'}).should include("chf=bg,lg,0,efefef,0,ffffff,1")
    Gchart::Gchart.sparkline(:bg => {:color => 'efefef,0,ffffff,1', :type => 'gradient'}).should include("chf=bg,lg,0,efefef,0,ffffff,1")
    Gchart::Gchart.sparkline(:bg => {:color => 'efefef', :type => 'gradient', :angle => 90}).should include("chf=bg,lg,90,efefef,0,ffffff,1")

    Gchart::Gchart.sparkline(:bg => {:color => 'efefef', :type => 'stripes'}).should include("chf=bg,ls,90,efefef,0.2,ffffff,0.2")
  end

  it "should be able to set a graph fill" do
    Gchart::Gchart.sparkline(:graph_bg => 'efefef').should include("chf=c,s,efefef")
    Gchart::Gchart.sparkline(:graph_bg => {:color => 'efefef', :type => 'solid'}).should include("chf=c,s,efefef")
    Gchart::Gchart.sparkline(:graph_bg => {:color => 'efefef', :type => 'gradient'}).should include("chf=c,lg,0,efefef,0,ffffff,1")
    Gchart::Gchart.sparkline(:graph_bg => {:color => 'efefef,0,ffffff,1', :type => 'gradient'}).should include("chf=c,lg,0,efefef,0,ffffff,1")
    Gchart::Gchart.sparkline(:graph_bg => {:color => 'efefef', :type => 'gradient', :angle => 90}).should include("chf=c,lg,90,efefef,0,ffffff,1")
  end

  it "should be able to set both a graph and a background fill" do
    Gchart::Gchart.sparkline(:bg => 'efefef', :graph_bg => '76A4FB').should match(/chf=(bg,s,efefef\|c,s,76A4FB|c,s,76A4FB\|bg,s,efefef)/)
  end

  it "should be able to have different line colors" do
    Gchart::Gchart.sparkline(:line_colors => 'efefef|00ffff').should include(Gchart::Gchart.jstize('chco=efefef|00ffff'))
    Gchart::Gchart.sparkline(:line_color => 'efefef|00ffff').should include(Gchart::Gchart.jstize('chco=efefef|00ffff'))
  end
end

describe "a 3d pie chart" do

  before(:each) do
    @title = 'Chart Title'
    @legend = ['first data set label', 'n data set label']
    @jstized_legend = Gchart::Gchart.jstize(@legend.join('|'))
    @data = [12,8,40,15,5]
    @chart = Gchart::Gchart.pie(:title => @title, :legend => @legend, :data => @data)
  end

  it "should create a pie" do
    @chart.should include('cht=p')
  end

  it "should be able to be in 3d" do
    Gchart::Gchart.pie_3d(:title => @title, :legend => @legend, :data => @data).should include('cht=p3')
  end
end

describe "a google-o-meter" do

  before(:each) do
    @data = [70]
    @legend = ['arrow points here']
    @jstized_legend = Gchart::Gchart.jstize(@legend.join('|'))
    @chart = Gchart::Gchart.meter(:data => @data)
  end

  it "should create a meter" do
    @chart.should include('cht=gom')
  end

  it "should be able to set a solid background fill" do
    Gchart::Gchart.meter(:bg => 'efefef').should include("chf=bg,s,efefef")
    Gchart::Gchart.meter(:bg => {:color => 'efefef', :type => 'solid'}).should include("chf=bg,s,efefef")
  end

  it "should be able to set labels by using the legend or labesl accessor" do
    Gchart::Gchart.meter(:title => @title, :labels => @legend, :data => @data).should include("chl=#{@jstized_legend}")
    Gchart::Gchart.meter(:title => @title, :labels => @legend, :data => @data).should == Gchart::Gchart.meter(:title => @title, :legend => @legend, :data => @data)
  end
end

describe "a map chart" do

  before(:each) do
    @data = [0,100,50,32]
    @geographical_area = 'usa'
    @map_colors = ['FFFFFF', 'FF0000', 'FFFF00', '00FF00']
    @country_codes = ['MT', 'WY', "ID", 'SD']
    @chart = Gchart::Gchart.map(:data => @data, :encoding => 'text', :size => '400x300',
      :geographical_area => @geographical_area, :map_colors => @map_colors,
      :country_codes => @country_codes)
  end

  it "should create a map" do
    @chart.should include('cht=t')
  end

  it "should set the geographical area" do
    @chart.should include('chtm=usa')
  end

  it "should set the map colors" do
    @chart.should include('chco=FFFFFF,FF0000,FFFF00,00FF00')
  end

  it "should set the country/state codes" do
    @chart.should include('chld=MTWYIDSD')
  end

  it "should set the chart data" do
    @chart.should include('chd=t:0,100,50,32')
  end
end

describe 'exporting a chart' do

  it "should be available in the url format by default" do
    Gchart::Line.new(:data => [0, 26], :format => 'url').draw.should == Gchart::Line.new(:data => [0, 26]).draw
  end

  it "should be available as an image tag" do
    Gchart::Line.new(:data => [0, 26], :format => 'image_tag').draw.should match(/<img src=(.*) width="300" height="200" alt="Google Chart" \/>/)
  end

  it "should be available as an image tag using img_tag alias" do
    Gchart::Line.new(:data => [0, 26], :format => 'img_tag').draw.should match(/<img src=(.*) width="300" height="200" alt="Google Chart" \/>/)
  end

  it "should be available as an image tag using custom dimensions" do
    Gchart::Line.new(:data => [0, 26], :format => 'image_tag', :size => '400x400').draw.should match(/<img src=(.*) width="400" height="400" alt="Google Chart" \/>/)
  end

  it "should be available as an image tag using custom alt text" do
    Gchart::Line.new(:data => [0, 26], :format => 'image_tag', :alt => 'Sexy chart').draw.should match(/<img src=(.*) width="300" height="200" alt="Sexy chart" \/>/)
  end

  it "should be available as an image tag using custom title text" do
    Gchart::Line.new(:data => [0, 26], :format => 'image_tag', :title => 'Sexy chart').draw.should match(/<img src=(.*) width="300" height="200" alt="Google Chart" title="Sexy chart" \/>/)
  end

  it "should be available as an image tag using custom css id selector" do
    Gchart::Line.new(:data => [0, 26], :format => 'image_tag', :id => 'chart').draw.should match(/<img id="chart" src=(.*) width="300" height="200" alt="Google Chart" \/>/)
  end

  it "should be available as an image tag using custom css class selector" do
    Gchart::Line.new(:data => [0, 26], :format => 'image_tag', :class => 'chart').draw.should match(/<img class="chart" src=(.*) width="300" height="200" alt="Google Chart" \/>/)
  end

  it "should use ampersands to separate key/value pairs in URLs by default" do
    Gchart::Line.new(:data => [0, 26]).draw.should include "&"
    Gchart::Line.new(:data => [0, 26]).draw.should_not include "&amp;"
  end

  it "should escape ampersands in URLs when used as an image tag" do
    Gchart::Line.new(:data => [0, 26], :format => 'image_tag', :class => 'chart').draw.should satisfy {|chart| chart.should include "&amp;" }
  end

  it "should be available as a file" do
    File.delete('chart.png') if File.exist?('chart.png')
    Gchart::Line.new(:data => [0, 26], :format => 'file').draw
    File.exist?('chart.png').should be_true
    File.delete('chart.png') if File.exist?('chart.png')
  end

  it "should be available as a file using a custom file name" do
    File.delete('custom_file_name.png') if File.exist?('custom_file_name.png')
    Gchart::Line.new(:data => [0, 26], :format => 'file', :filename => 'custom_file_name.png').draw
    File.exist?('custom_file_name.png').should be_true
    File.delete('custom_file_name.png') if File.exist?('custom_file_name.png')
  end

  it "should work even with multiple attrs" do
    File.delete('foo.png') if File.exist?('foo.png')
    Gchart::Line.new(:size => '400x200',
                :data => [1,2,3,4,5],
                # :axis_labels => [[1,2,3,4, 5], %w[foo bar]],
                :axis_with_labels => 'x,r',
                :format => "file",
                :filename => "foo.png"
                ).draw
    File.exist?('foo.png').should be_true
    File.delete('foo.png') if File.exist?('foo.png')
  end
end

describe 'SSL support' do
  it 'should change url if is presented' do
    Gchart::Line.new(:use_ssl => true).draw.should include('https://chart.googleapis.com/chart?')
  end

  it "should be available as a file" do
    pending "unexpected error under Travis CI (should be fixed using http://martinottenwaelter.fr/2010/12/ruby19-and-the-ssl-error/)"
    File.delete('chart.png') if File.exist?('chart.png')
    Gchart::Line.new(:data => [0, 26], :format => 'file', :use_ssl => true).draw
    File.exist?('chart.png').should be_true
    File.delete('chart.png') if File.exist?('chart.png')
  end
end

