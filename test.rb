require 'gy.rb'
include MyMethods
describe Object, "Reject campのテストコード" do
  before do
    @a = exampletree
  end
  it "exampletreeメソッドで生成されるNodeオブジェクトが正しく生成されている" do
     @a.children[0].name.should == "isgreater"
     @a.children[0].children[0].idx.should == 0
     @a.children[0].function.class.should == Method 
  end
end
