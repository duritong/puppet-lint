require 'spec_helper'

describe 'variable_scope' do
  let(:msg) { 'top-scope variable being used without an explicit namespace' }

  context 'class with no variables declared accessing top scope' do
    let(:code) { "
      class foo {
        $bar = $baz
      }"
    }

    it 'should only detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create a warning' do
      expect(problems).to contain_warning(msg).on_line(3).in_column(16)
    end
  end

  context 'class with no variables declared accessing top scope explicitly' do
    let(:code) { "
      class foo {
        $bar = $::baz
      }"
    }

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'class with variables declared accessing local scope' do
    let(:code) { "
      class foo {
        $bar = 1
        $baz = $bar
      }"
    }

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'class with parameters accessing local scope' do
    let(:code) { "
      class foo($bar='UNSET') {
        $baz = $bar
      }"
    }

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'defined type with no variables declared accessing top scope' do
    let(:code) { "
      define foo() {
        $bar = $fqdn
      }"
    }

    it 'should only detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create a warning' do
      expect(problems).to contain_warning(msg).on_line(3).in_column(16)
    end
  end

  context 'defined type with no variables declared accessing top scope explicitly' do
    let(:code) { "
      define foo() {
        $bar = $::fqdn
      }"
    }

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context '$name should be auto defined' do
    let(:code) { "
      define foo() {
        $bar = $name
        $baz = $title
        $gronk = $module_name
        $meep = $1
      }"
    }

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'define with required parameter' do
    let(:code) { "
      define tomcat::base (
          $max_perm_gen,
          $owner = hiera('app_user'),
          $system_properties = {},
      ) {  }"
    }

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'future parser blocks' do
    let(:code) { "
      class foo() {
        $foo = [1,2]
        $foo.each |$a, $b| {
          $a
          $c
        }
        $b
      }
    " }

    it 'should only detect a single problem' do
      expect(problems).to have(2).problem
    end

    it 'should create two warnings' do
      expect(problems).to contain_warning(msg).on_line(8).in_column(9)
      expect(problems).to contain_warning(msg).on_line(6).in_column(11)
    end
  end
end
