The goal of this Gem is to make the creation of Google Charts a simple and easy task.

Gchart.line(  :size => '200x300', 
              :title => "example title",
              :bg => 'efefef',
              :legend => ['first data set label', 'second data set label'],
              :data => [10, 30, 120, 45, 72])
              


==Chart Type

This gem supports the following types of charts:
  
  * line, 
  * line_xy
  * scatter
  * bar
  * venn
  * pie
  * pie_3d

To create a chart, simply require Gchart and call any of the existing type:

    require 'gchart'
    Gchart.pie
  
  
==Chart Title

  To add a title to a chart pass the title to your chart:
  
    Gchart.line(:title => 'Sexy Charts!')
    
You can also specify the color and/or size
    
    Gchart.line(:title => 'Sexy Charts!', :title_color => 'FF0000', :title_size => '20')

==Colors

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

===Background options:

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
    
    
== Legend & Labels

You probably will want to use a legend or labels for your graph.

    Gchart.line(:legend => 'legend label')
or
    Gchart.line(:legend => ['legend label 1', 'legend label 2'])
    
Will do the trick. You can also use the labels alias (makes more sense when using the pie charts)

    chart = Gchart.pie(:labels => ['label 1', 'label 2'])

== Multiple axis labels 

Multiple axis labels are available for line charts, bar charts and scatter plots.

* x = bottom x-axis
* t = top x-axis
* y = left y-axis
* r = right y-axis

    Gchart.line(:label_axis => 'x,y,r')
  
To add labels on these axis:

    Gchart.line(:axis_labels => ['Jan|July|Jan|July|Jan', '0|100', 'A|B|C', '2005|2006|2007'])

    
== Data options

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
  

==Pies:
  
you have 2 type of pies:
  - Gchart.pie() the standard 2D pie
  _ Gchart.pie_3d() the fancy 3D pie
  
To set labels, you can use one of these two options:

    @legend = ['Matt_fu', 'Rob_fu']
    Gchart.pie_3d(:title => @title, :labels => @legend, :data => @data, :size => '400x200')
    Gchart.pie_3d(:title => @title, :legend => @legend, :data => @data, :size => '400x200')
  
  
  
=== try yourself

Gchart.bar( :data => [[1,2,4,67,100,41,234],[45,23,67,12,67,300, 250]], 
            :title => 'SDRuby Fu level', 
            :legend => ['matt','patrick'], 
            :bg => {:color => '76A4FB', :type => 'gradient'}, 
            :bar_colors => 'ff0000,00ff00')

 "http://chart.apis.google.com/chart?chs=300x200&chdl=matt|patrick&chd=s:AAANUIv,JENCN9y&chtt=SDRuby+Fu+level&chf=bg,lg,0,76A4FB,0,ffffff,1&cht=bvs&chco=ff0000,00ff00"  
 
Gchart.pie(:data => [20,10,15,5,50], :title => 'SDRuby Fu level', :size => '400x200', :labels => ['matt', 'rob', 'patrick', 'ryan', 'jordan'])
http://chart.apis.google.com/chart?cht=p&chs=400x200&chd=s:YMSG9&chtt=SDRuby+Fu+level&chl=matt|rob|patrick|ryan|jordan
