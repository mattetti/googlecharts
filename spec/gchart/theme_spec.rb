require 'spec_helper.rb'

describe "generating a default Gchart" do
  it 'should be able to add additional theme files' do
    Gchart::Theme.theme_files.should_not include('./spec/fixtures/another_test_theme.yml')
    Gchart::Theme.add_theme_file('./spec/fixtures/another_test_theme.yml')
    Gchart::Theme.theme_files.should include('./spec/fixtures/another_test_theme.yml')
  end

  it 'should be able to load themes from the additional theme files' do
    lambda { Gchart::Theme.load(:test_two) }.should_not raise_error
  end

  it 'should raise ThemeNotFound if theme does not exist' do
    lambda { Gchart::Theme.load(:nonexistent) }.should raise_error(Gchart::Theme::ThemeNotFound, "Could not locate the nonexistent theme ...")
  end

  it 'should set colors array' do
    Gchart::Theme.load(:keynote).colors.should eql(["6886B4", "FDD84E", "72AE6E", "D1695E", "8A6EAF", "EFAA43", "FFFFFF", "000000"])
  end

  it 'should set bar colors array' do
    Gchart::Theme.load(:keynote).bar_colors.should eql(["6886B4", "FDD84E", "72AE6E", "D1695E", "8A6EAF", "EFAA43"])
  end

  it 'should set background' do
    Gchart::Theme.load(:keynote).background.should eql("000000")
  end

  it 'should set chart background' do
    Gchart::Theme.load(:keynote).chart_background.should eql("FFFFFF")
  end
end
