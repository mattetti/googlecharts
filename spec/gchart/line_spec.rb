require 'spec_helper'

describe Gchart::Line do
  describe :methods do
    describe :type do
      it 'should return lc' do
        subject.type.should == 'lc'
      end
    end

    describe :initialize do
      context 'default values' do
        it "should create a line break when a pipe character is encountered" do
          described_class.new(:title => "title|subtitle").draw.should include("chtt=title\nsubtitle")
        end

        it "should have query parameters in predictable order" do
          described_class.new(:axis_with_labels => 'x,y,r', :size => '400x600').draw.should match(/chxt=.+cht=.+chs=/)
        end

        it "should be able to receive a custom param" do
          described_class.new(:custom => 'ceci_est_une_pipe').draw.should include('ceci_est_une_pipe')
        end

        it "should be able to set label axis" do
          described_class.new(:axis_with_labels => 'x,y,r').draw.should include('chxt=x,y,r')
          described_class.new(:axis_with_labels => ['x','y','r']).draw.should include('chxt=x,y,r')
        end

        context 'custom size 'do
          it "should be able to accept size as a string if width x height" do
            described_class.new(:size => '400x600').draw.should include('chs=400x600')
          end

          it 'should accepts size as width and height hashes' do
            described_class.new(:width => 400, :height => 600).draw.should include('chs=400x600')
          end
        end
      end
    end
  end
end
