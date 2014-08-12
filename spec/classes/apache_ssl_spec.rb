require 'spec_helper'

describe 'apache::ssl' do
  let(:pre_condition) { "
class concat::setup {}
define concat() {}
define concat::fragment($ensure='present', $target, $content) {}
  " }

  OSES.each do |os|
    describe "When on #{os}" do
      let(:facts) { {
        :operatingsystem          => os,
        :operatingsystemrelease   => '5.5',
        :lsbmajdistrelease        => '5',
      } }

      if ['Debian', 'Ubuntu'].include? os
        it { should contain_class('apache::ssl::debian') }
      elsif ['RedHat', 'CentOS'].include? os
        it { should contain_class('apache::ssl::redhat') }
      end
    end
  end

  describe 'When on unknown OS' do
    let(:facts) { {
      :operatingsystem => 'Fedora',
    } }

    it do
      expect {
        should contain_class('apache::ssl::debian')
      }.to raise_error(Puppet::Error, /Unsupported operatingsystem Fedora/)
    end
  end
end
