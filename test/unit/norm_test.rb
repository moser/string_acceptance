require File.dirname(__FILE__) + '/../../test/test_helper'

class OtherChild < ActiveRecord::Base
  set_table_name "child_things"
  belongs_to :thing
  accepts_string_for :thing, :create => false, :parent_method => :lala
end

class Child3 < ActiveRecord::Base
  set_table_name "child_things"
  belongs_to :thing
  accepts_string_for :thing, :create => false, :parent_method => [:name, :lala]
end

class Child4 < ActiveRecord::Base
  set_table_name "child_things"
  belongs_to :thing
  accepts_string_for :thing, :ignore_case => false, :create => false
end

class Child5 < ActiveRecord::Base
  set_table_name "child_things"
  belongs_to :thing
  accepts_string_for :thing, :create => false
end

class Child6 < ActiveRecord::Base
  set_table_name "child_things"
  belongs_to :thing
  accepts_string_for :thing, :create => false, :ignore_case => false, :parent_method => [:name, :lala]
end

class Child7 < ActiveRecord::Base
  set_table_name "child_things"
  belongs_to :thing
  accepts_string_for :thing, :create => false, :may_nil => false
end

class NormTest < Test::Unit::TestCase
  def setup
    OtherChild.destroy_all
    ChildThing.destroy_all
    Thing.destroy_all
  end
  
  def test_should_accept_string
    str = "NewName"
    ct = ChildThing.new
    ct.thing = str
    assert_equal str, ct.thing.name
  end
  
  def test_should_accept_object
    str = "OtherName"
    t = Thing.new({:name => str})
    t.save
    ct = ChildThing.new
    ct.thing = t
    assert_equal t.id, ct.thing_id
  end
  
  def test_should_find_existing_object
    str = "OtherName"
    t = Thing.new({:name => str})
    t.save
    ct = ChildThing.new
    ct.thing = str
    assert_equal t.id, ct.thing_id
  end
  
  def test_should_not_create_new_object
    str = "lala"
    ct = OtherChild.new
    ct.thing = str
    assert_nil ct.thing
  end
  
  def test_should_append_an_error
    str = "lala"
    ct = OtherChild.new
    ct.thing = str
    assert !ct.save
    assert_not_nil ct.errors.on(:thing)
  end
  
  def test_should_find_by_lala
    str = "OtherLala"
    t = Thing.new({:lala => str})
    t.save
    ct = OtherChild.new
    ct.thing = str
    assert_equal t.id, ct.thing_id
  end
  
  def test_should_find_by_name_or_lala
    name = "sdaldsdfsdfasf"
    lala = "sadfas"
    t = Thing.create({:name => name, :lala => lala})
    ct = Child3.new
    ct.thing = name
    assert_equal t.id, ct.thing_id
    ct.thing = nil
    assert_nil ct.thing_id
    ct.thing = lala
    assert_equal t.id, ct.thing_id
  end
  
  def test_should_not_ignore_case
    name = 'AbCdEfG'
    lala = 'aBcDeFg'
    t = Thing.create(:name => name, :lala => lala)
    ct = Child4.new
    ct.thing = name.downcase
    assert_nil ct.thing
    ct = Child6.new
    ct.thing = name.downcase
    assert_nil ct.thing
    ct.thing = lala.downcase
    assert_nil ct.thing
  end
  
  def test_should_ignore_case
    name = 'AbCdEfG'
    lala = 'aBcDeFg'
    t = Thing.create(:name => name, :lala => lala)
    ct = Child5.new
    ct.thing = name.downcase
    assert_equal t, ct.thing
    ct = Child3.new
    ct.thing = name.downcase
    assert_equal t, ct.thing
    ct.thing = lala.downcase
    assert_equal t, ct.thing
  end
  
  def test_may_not_nil
    name = "aa"
    non_existant_name = "bb"
    t = Thing.create(:name => name)
    ct = Child7.create(:thing => name)
    assert_equal t, ct.thing
    ct.thing = non_existant_name
    assert_equal t, ct.thing
  end
  
end
