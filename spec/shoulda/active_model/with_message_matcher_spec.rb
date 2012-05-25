require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::WithMessageMatcher do
  let(:matcher_class) { Shoulda::Matchers::ActiveModel::WithMessageMatcher }

  context 'when attribute is invalid' do
    it 'matches when the error message matches' do
      attribute = :age
      non_numeric_value = 'a string'
      expected_message = "oh no"

      model = define_active_model_class(:example, :accessors => [attribute]) do
        validates attribute, :numericality => { :message => expected_message }
      end.new

      matcher = matcher_class.new(attribute, non_numeric_value, expected_message)
      matcher.matches?(model).should be_true
    end

    it 'matches when the error message is nil' do
      attribute = :age
      non_numeric_value = 'a string'
      expected_message = nil

      model = define_active_model_class(:example, :accessors => [attribute]) do
        validates attribute, :numericality => { :message => expected_message }
      end.new

      matcher = matcher_class.new(attribute, non_numeric_value, expected_message)
      matcher.matches?(model).should be_true
    end

    it 'does not match when the error message does not match' do
      attribute = :age
      non_numeric_value = 'a string'
      actual_message = 'for real'
      expected_message = 'not matching'

      model = define_active_model_class(:example, :accessors => [attribute]) do
        validates attribute, :numericality => { :message => actual_message }
      end.new

      matcher = matcher_class.new(attribute, non_numeric_value, expected_message)
      matcher.matches?(model).should be_false
    end

    it 'does not match when the expected error message is a substring of the actual one' do
      attribute = :age
      non_numeric_value = 'a string'
      actual_message = 'substring'
      expected_message = 'sub'

      model = define_active_model_class(:example, :accessors => [attribute]) do
        validates attribute, :numericality => { :message => actual_message }
      end.new

      matcher = matcher_class.new(attribute, non_numeric_value, expected_message)
      matcher.matches?(model).should be_false
    end
  end

  context 'when attribute is valid' do
    it 'does not match even when error message matches' do
      attribute = :age
      good_value = 1
      message = "oh no"

      model = define_active_model_class(:example, :accessors => [attribute]) do
        validates attribute, :numericality => { :message => message }
      end.new

      matcher = matcher_class.new(attribute, good_value, message)
      matcher.matches?(model).should be_false
    end

    it 'does not match when error message does not match' do
      attribute = :age
      good_value = 1
      actual_message = 'for real'
      expected_message = 'not matching'

      model = define_active_model_class(:example, :accessors => [attribute]) do
        validates attribute, :numericality => { :message => actual_message }
      end.new

      matcher = matcher_class.new(attribute, good_value, expected_message)
      matcher.matches?(model).should be_false
    end
  end

  context 'given a regex to match against' do
    it 'matches when error message matches regex' do
      attribute = :age
      non_numeric_value = 'a string'
      message = 'foo bar'
      regex_matching_message = /foo/

      model = define_active_model_class(:example, :accessors => [attribute]) do
        validates attribute, :numericality => { :message => message }
      end.new

      matcher = matcher_class.new(attribute, non_numeric_value, regex_matching_message)
      matcher.matches?(model).should be_true
    end
  end

  context '#failure_message' do
    it 'provides a failure message' do
      attribute = :attr
      bad_value = nil
      actual_message = 'is not blank'
      expected_message = 'not matching'

      model = define_active_model_class(:example, :accessors => [attribute]) do
        validates attribute, :presence => { :message => actual_message }
      end.new

      expected_failure_message = %{Expected #{expected_message}, got ["#{attribute} #{actual_message} (#{bad_value.inspect})"]}

      matcher = matcher_class.new(attribute, bad_value, expected_message)
      matcher.matches?(model)
      matcher.failure_message.should == expected_failure_message
    end

    it 'is correct when model has more than one error' do
      attribute = :age
      other_attribute = :name
      bad_value = nil
      actual_message = 'for real'
      expected_message = 'not matching'

      model = define_active_model_class(:example, :accessors => [attribute, other_attribute]) do
        validates attribute, :presence => { :message => actual_message }
        validates other_attribute, :presence => { :message => 'other message' }
      end.new

      expected_failure_message = %{Expected #{expected_message}, got ["age #{actual_message} (nil)", "name other message (nil)"]}
      matcher = matcher_class.new(attribute, bad_value, expected_message)
      matcher.matches?(model)
      matcher.failure_message.should == expected_failure_message
    end
  end
end
