The goal of this Gem is to make the creation of Google Charts a simple and easy task.
    
    require 'googlecharts'
    Gchart.line(  :size => '200x300', 
                  :title => "example title",
                  :bg => 'efefef',
                  :legend => ['first data set label', 'second data set label'],
                  :data => [10, 30, 120, 45, 72])
              

Check out the [full documentation over there](http://googlecharts.rubyforge.org/)

This gem is fully tested using Rspec, check the rspec folder for more examples.

See at the bottom of this file who reported using this gem.

Chart Type
-------------

This gem supports the following types of charts:
  
  * line, 
  * line_xy
  * sparkline
  * scatter
  * bar
  * venn
  * pie
  * pie_3d
  * google meter
  
Googlecharts also supports graphical themes and you can easily load your own.

To create a chart, simply require Gchart and call any of the existing type:

    require 'gchart'
    Gchart.pie
  
  
Chart Title
-------------

  To add a title to a chart pass the title to your chart:
  
    Gchart.line(:title => 'Sexy Charts!')
    
You can also specify the color and/or size
    
    Gchart.line(:title => 'Sexy Charts!', :title_color => 'FF0000', :title_size => '20')

Colors
-------------

Specify a color with at least a 6-letter string of hexadecimal values in the format RRGGBB. For example:

    * FF0000 = red
    * 00FF00 = green
    * 0000FF = blue
    * 000000 = black
    * FFFFFF = white

You can optionally specify transparency by appending a value between 00 and FF where 00 is completely transparent and FF completely opaque. For example:

    * 0000FFFF = solid blue
    * 0000FF00 = transparent blue

If you need to use multiple colors, check the doc. Usually you just need to pass :attribute => 'FF0000,00FF00'

Some charts have more options than other, make sure to refer to the documentation.

Background options:
-------------

If you don't set the background option, your graph will be transparent.

* You have 3 types of background  http://code.google.com/apis/chart/#chart_or_background_fill

- solid
- gradient
- stripes

By default, if you set a background color, the fill will be solid:

    Gchart.bar(:bg => 'efefef')

However you can specify another fill type such as:
            
    Gchart.line(:bg => {:color => 'efefef', :type => 'gradient'})
  
In the above code, we decided to have a gradient background, however since we only passed one color, the chart will start by the specified color and transition to white. By the default, the gradient angle is 0. Change it as follows:

    Gchart.line(:title =>'bg example', :bg => {:color => 'efefef', :type => 'gradient', :angle => 90})
    
For a more advance use of colors, refer to http://code.google.com/apis/chart/#linear_gradient

    Gchart.line(:bg => {:color => '76A4FB,1,ffffff,0', :type => 'gradient'})
    
    
The same way you set the background color, you can also set the graph background:

    Gchart.line(:graph_bg => 'cccccc')
    
or both

    Gchart.line(:bg => {:color => '76A4FB,1,ffffff,0', :type => 'gradient'}, :graph_bg => 'cccccc', :title => 'Sexy Chart')
    
    
Another type of fill is stripes http://code.google.com/apis/chart/#linear_stripes

    Gchart.line(:bg => {:color => 'efefef', :type => 'stripes'})
    
You can customize the amount of stripes, colors and width by changing the color value.


Themes
--------

  Googlecharts comes with 4 themes: keynote, thirty7signals, pastel and greyscale. (ganked from [Gruff](http://github.com/topfunky/gruff/tree/master)


    Gchart.line(
                :theme => :keynote, 
                :data => [[0,40,10,70,20],[41,10,80,50,40],[20,60,30,60,80],[5,23,35,10,56],[80,90,5,30,60]], 
                :title => 'keynote'
                )

  * keynote

    ![keynote](http://chart.apis.google.com/chart?chtt=keynote&chco=6886B4,FDD84E,72AE6E,D1695E,8A6EAF,EFAA43&chs=300x200&cht=lc&chd=s:AbGvN,bG2hb,NoUo2,DPXGl,29DUo&chf=c,s,FFFFFF|bg,s,000000)

  * thirty7signals

    ![37signals](http://chart.apis.google.com/chart?chtt=thirty7signals&chco=FFF804,336699,339933,ff0000,cc99cc,cf5910&chs=300x200&cht=lc&chd=s:AbGvN,bG2hb,NoUo2,DPXGl,29DUo&chf=bg,s,FFFFFF)

  * pastel

    ![pastel](http://chart.apis.google.com/chart?chtt=pastel&chco=a9dada,aedaa9,daaea9,dadaa9,a9a9da&chs=300x200&cht=lc&chd=s:AbGvN,bG2hb,NoUo2,DPXGl,29DUo)

  * greyscale

    ![greyscale](http://chart.apis.google.com/chart?chtt=greyscale&chco=282828,383838,686868,989898,c8c8c8,e8e8e8&chs=300x200&cht=lc&chd=s:AbGvN,bG2hb,NoUo2,DPXGl,29DUo)


You can also use your own theme. Create a yml file using the same format as the themes located in lib/themes.yml

Load your theme(s):

      Chart::Theme.add_theme_file("#{File.dirname(__FILE__)}/fixtures/another_test_theme.yml")

And use the standard method signature to use your own theme:

      Gchart.line(:theme => :custom_theme, :data => [[0, 40, 10, 70, 20],[41, 10, 80, 50]], :title => 'greyscale')

    
    
Legend & Labels
-------------

You probably will want to use a legend or labels for your graph.

    Gchart.line(:legend => 'legend label')
or
    Gchart.line(:legend => ['legend label 1', 'legend label 2'])
    
Will do the trick. You can also use the labels alias (makes more sense when using the pie charts)

    chart = Gchart.pie(:labels => ['label 1', 'label 2'])

Multiple axis labels 
-------------

Multiple axis labels are available for line charts, bar charts and scatter plots.

* x = bottom x-axis
* t = top x-axis
* y = left y-axis
* r = right y-axis

    Gchart.line(:axis_with_label => 'x,y,r,t')
  
To add labels on these axis:

    Gchart.line(:axis_with_label => 'x,y,r,t',
                :axis_labels => ['Jan|July|Jan|July|Jan', '0|100', 'A|B|C', '2005|2006|2007'])

Note that each array entry could also be an array but represent the
labels for the corresponding axis.

A question which comes back often is how do I only display the y axis
label? Solution:

    Gchart.line(
            :data => [0,20, 40, 60, 140, 230, 60],
            :axis_with_labels => 'y')

Custom axis ranges
---------------

If you want to display a custom range for an axis, you need to set the
range as described in the Google charts documentation: min, max, step:

     Gchart.line( :data => [17, 17, 11, 8, 2], 
                  :axis_with_labels => ['x', 'y'], 
                  :axis_labels => [['J', 'F', 'M', 'A', 'M']], 
                  :axis_range => [nil, [2,17,5]])


In this case, the custom axis range is only defined for y (second
entry) with a minimum value of 2, max 17 and a step of 5.

This is also valid if you want to set a x axis and automatically define
the y labels.
    

Data options
-------------

Data are passed using an array or a nested array.    

    Gchart.bar(:data => [1,2,4,67,100,41,234])  
  
    Gchart.bar(:data => [[1,2,4,67,100,41,234],[45,23,67,12,67,300, 250]])
  
By default, the graph is drawn with your max value representing 100% of the height or width of the graph. You can change that my passing the max value.

    Gchart.bar(:data => [1,2,4,67,100,41,234], :max_value => 300)
    Gchart.bar(:data => [1,2,4,67,100,41,234], :max_value => 'auto')
  
or if you want to use the real values from your dataset:

    Gchart.bar(:data => [1,2,4,67,100,41,234], :max_value => false)
  
  
You can also define a different encoding to add more granularity:

    Gchart.bar(:data => [1,2,4,67,100,41,234], :encoding => 'simple') 
    Gchart.bar(:data => [1,2,4,67,100,41,234], :encoding => 'extended') 
    Gchart.bar(:data => [1,2,4,67,100,41,234], :encoding => 'text') 
  

Pies:
-------------
  
you have 2 type of pies:
  - Gchart.pie() the standard 2D pie
  _ Gchart.pie_3d() the fancy 3D pie
  
To set labels, you can use one of these two options:

    @legend = ['Matt_fu', 'Rob_fu']
    Gchart.pie_3d(:title => @title, :labels => @legend, :data => @data, :size => '400x200')
    Gchart.pie_3d(:title => @title, :legend => @legend, :data => @data, :size => '400x200')
  
Bars:
-------------

A bar chart can accept options to set the width of the bars, spacing between bars and spacing between bar groups. To set these, you can either provide a string, array or hash.

The Google API sets these options in the order of width, spacing, and group spacing, with both spacing values being optional. So, if you provide a string or array, provide them in that order:

    Gchart.bar(:data => @data, :bar_width_and_spacing => '25,6') # width of 25, spacing of 6
    Gchart.bar(:data => @data, :bar_width_and_spacing => '25,6,12') # width of 25, spacing of 6, group spacing of 12
    Gchart.bar(:data => @data, :bar_width_and_spacing => [25,6]) # width of 25, spacing of 6
    Gchart.bar(:data => @data, :bar_width_and_spacing => 25) # width of 25
  
The hash lets you set these values directly, with the Google default values set for any options you don't include:

    Gchart.bar(:data => @data, :bar_width_and_spacing => {:width => 19})
    Gchart.bar(:data => @data, :bar_width_and_spacing => {:spacing => 10, :group_spacing => 12})

Radar:
-------------
    In a Radar graph, the x-axis is circular. The points can be connected by straight lines or curved lines.
    Gchart.radar(:data => @data, :curved => true)

Sparklines:
-------------

A sparkline chart has exactly the same parameters as a line chart. The only difference is that the axes lines are not drawn for sparklines by default.
  

Google-o-meter
-------------

A Google-o-meter has a few restrictions. It may only use a solid filled background and it may only have one label.

Record Chart PNG file in filesystem Sample :
--------------------------------------------

Multi Lines Chart Sample :

	chart = Gchart.new(	:type => 'line',
						:title => "example title",
						:data => [[17, 17, 11, 8, 2],[10, 20, 15, 5, 7],[2, 3, 7, 9, 12]], 
						:line_colors => 'e0440e,e62ae5,287eec',
						:legend => ['courbe 1','courbe 2','courbe 3'],
						:axis_with_labels => ['x', 'y'], 
						:axis_range => [[0,100,20], [0,20,5]],
						:filename => "tmp/chart.png")
			
	# Record file in filesystem
	chart.file

try yourself
-------------

    Gchart.bar( :data => [[1,2,4,67,100,41,234],[45,23,67,12,67,300, 250]], 
                :title => 'SD Ruby Fu level', 
                :legend => ['matt','patrick'], 
                :bg => {:color => '76A4FB', :type => 'gradient'}, 
                :bar_colors => 'ff0000,00ff00')

 "http://chart.apis.google.com/chart?chs=300x200&chdl=matt|patrick&chd=s:AAANUIv,JENCN9y&chtt=SDRuby+Fu+level&chf=bg,lg,0,76A4FB,0,ffffff,1&cht=bvs&chco=ff0000,00ff00"  
 
    Gchart.pie(:data => [20,10,15,5,50], :title => 'SDRuby Fu level', :size => '400x200', :labels => ['matt', 'rob', 'patrick', 'ryan', 'jordan'])
http://chart.apis.google.com/chart?cht=p&chs=400x200&chd=s:YMSG9&chtt=SDRuby+Fu+level&chl=matt|rob|patrick|ryan|jordan