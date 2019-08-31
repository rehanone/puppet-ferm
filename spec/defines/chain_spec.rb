require 'spec_helper'

describe 'ferm::chain', type: :define do
  on_supported_os.each do |os, facts|
    context "on #{os} " do
      let :facts do
        facts
      end
      let(:title) { 'INPUT2' }

      let :pre_condition do
        'include ferm'
      end

      context 'default params creates INPUT2 chain' do
        let :params do
          {
            policy: 'DROP',
            disable_conntrack: false,
            log_dropped_packets: true
          }
        end

        it { is_expected.to compile.with_all_deps }
        it do
          is_expected.to contain_concat__fragment('INPUT2-policy'). \
            with_content(%r{ESTABLISHED RELATED})
        end
        it do
          is_expected.to contain_concat__fragment('INPUT2-footer'). \
            with_content(%r{LOG log-prefix 'INPUT2: ';})
        end
        if facts[:os]['release']['major'].to_i == 10
          it { is_expected.to contain_concat('/etc/ferm/ferm.d/chains/INPUT2.conf') }
        else
          it { is_expected.to contain_concat('/etc/ferm.d/chains/INPUT2.conf') }
        end
        it { is_expected.to contain_ferm__chain('INPUT2') }
      end

      context 'without conntrack' do
        let :params do
          {
            policy: 'DROP',
            disable_conntrack: true,
            log_dropped_packets: false
          }
        end

        it { is_expected.to compile.with_all_deps }
        it do
          is_expected.to contain_concat__fragment('INPUT2-policy')
          is_expected.not_to contain_concat__fragment('INPUT2-policy'). \
            with_content(%r{ESTABLISHED RELATED})
        end
        it do
          is_expected.not_to contain_concat__fragment('INPUT2-footer'). \
            with_content(%r{LOG log-prefix 'INPUT2: ';})
        end
      end
    end
  end
end
