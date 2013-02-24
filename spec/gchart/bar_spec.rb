require 'spec_helper'

describe Gchart::Bar do
  describe :methods do
    describe :type do
      it 'should return lc' do
        subject.type.should == 'bvs'
      end
    end
  end

  it 'should generate different labels and legend' do
    described_class.new(:legend => %w(1 2 3), :labels=>%w(one two three)).draw.should(include('chdl=1|2|3') && include('chl=one|two|three'))
  end

  it "should have a default vertical orientation" do
    described_class.new.draw.should include('cht=bvs')
  end

  it "should be able to have a different orientation" do
    described_class.new(:orientation => 'vertical').draw.should include('cht=bvs')
    described_class.new(:orientation => 'v').draw.should include('cht=bvs')
    described_class.new(:orientation => 'h').draw.should include('cht=bhs')
    described_class.new(:orientation => 'horizontal').draw.should include('cht=bhs')
    described_class.new(:horizontal => false).draw.should include('cht=bvs')
  end

  it "should be set to be stacked by default" do
    described_class.new.draw.should include('cht=bvs')
  end

  it "should be able to stacked, grouped or overlapped" do
    described_class.new(:stacked => true).draw.should include('cht=bvs')
    described_class.new(:stacked => false).draw.should include('cht=bvs')
    described_class.new(:grouped => true).draw.should include('cht=bvg')
    described_class.new(:grouped => false).draw.should include('cht=bvs')
    described_class.new(:overlapped => true).draw.should include('cht=bvo')
    described_class.new(:overlapped => false).draw.should include('cht=bvs')
  end

  it "should be able to have different bar colors" do
    described_class.new(:bar_colors => 'efefef,00ffff').draw.should include('chco=')
    described_class.new(:bar_colors => 'efefef,00ffff').draw.should include('chco=efefef,00ffff')
    # alias
    described_class.new(:bar_color => 'efefef').draw.should include('chco=efefef')
  end

  it "should be able to have different bar colors when using an array of colors" do
    described_class.new(:bar_colors => ['efefef','00ffff']).draw.should include('chco=efefef,00ffff')
  end

  it 'should be able to accept a string of width and spacing options' do
    described_class.new(:bar_width_and_spacing => '25,6').draw.should include('chbh=25,6')
  end

  it 'should be able to accept a single fixnum width and spacing option to set the bar width' do
    described_class.new(:bar_width_and_spacing => 25).draw.should include('chbh=25')
  end

  it 'should be able to accept an array of width and spacing options' do
    described_class.new(:bar_width_and_spacing => [25,6,12]).draw.should include('chbh=25,6,12')
    described_class.new(:bar_width_and_spacing => [25,6]).draw.should include('chbh=25,6')
    described_class.new(:bar_width_and_spacing => [25]).draw.should include('chbh=25')
  end

  describe "with a hash of width and spacing options" do

    before(:each) do
      @default_width         = 23
      @default_spacing       = 4
      @default_group_spacing = 8
    end

    it 'should be able to have a custom bar width' do
      described_class.new(:bar_width_and_spacing => {:width => 19}).draw.should include("chbh=19,#{@default_spacing},#{@default_group_spacing}")
    end

    it 'should be able to have custom spacing' do
      described_class.new(:bar_width_and_spacing => {:spacing => 19}).draw.should include("chbh=#{@default_width},19,#{@default_group_spacing}")
    end

    it 'should be able to have custom group spacing' do
      described_class.new(:bar_width_and_spacing => {:group_spacing => 19}).draw.should include("chbh=#{@default_width},#{@default_spacing},19")
    end
  end
end
