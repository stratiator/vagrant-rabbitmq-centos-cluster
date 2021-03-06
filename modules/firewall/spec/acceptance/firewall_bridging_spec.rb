 require 'spec_helper_acceptance'

describe 'firewall type', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do

  describe 'reset' do
    it 'deletes all iptables rules' do
      shell('iptables --flush; iptables -t nat --flush; iptables -t mangle --flush')
    end
    it 'deletes all ip6tables rules' do
      shell('ip6tables --flush; ip6tables -t nat --flush; ip6tables -t mangle --flush')
    end
  end

  describe 'iptables physdev tests' do
    context 'physdev_in eth0' do
        it 'applies' do
          pp = <<-EOS
            class { '::firewall': }
            firewall { '701 - test':
              chain => 'FORWARD',
              proto  => tcp,
              port   => '701',
              action => accept,
              physdev_in => 'eth0',
            }
          EOS

          apply_manifest(pp, :catch_failures => true)
          unless fact('selinux') == 'true'
            apply_manifest(pp, :catch_changes => true)
          end
        end

        it 'should contain the rule' do
           shell('iptables-save') do |r|
             expect(r.stdout).to match(/-A FORWARD -p tcp -m physdev\s+--physdev-in eth0 -m multiport --ports 701 -m comment --comment "701 - test" -j ACCEPT/)
           end
        end
      end

      context 'physdev_out eth1' do
        it 'applies' do
          pp = <<-EOS
            class { '::firewall': }
            firewall { '702 - test':
              chain => 'FORWARD',
              proto  => tcp,
              port   => '702',
              action => accept,
              physdev_out => 'eth1',
            }
          EOS

          apply_manifest(pp, :catch_failures => true)
          unless fact('selinux') == 'true'
            apply_manifest(pp, :catch_changes => true)
          end
        end

        it 'should contain the rule' do
           shell('iptables-save') do |r|
             expect(r.stdout).to match(/-A FORWARD -p tcp -m physdev\s+--physdev-out eth1 -m multiport --ports 702 -m comment --comment "702 - test" -j ACCEPT/)
           end
        end
      end

      context 'physdev_in eth0 and physdev_out eth1' do
        it 'applies' do
          pp = <<-EOS
            class { '::firewall': }
            firewall { '703 - test':
              chain => 'FORWARD',
              proto  => tcp,
              port   => '703',
              action => accept,
              physdev_in => 'eth0',
              physdev_out => 'eth1',
            }
          EOS

          apply_manifest(pp, :catch_failures => true)
          unless fact('selinux') == 'true'
            apply_manifest(pp, :catch_changes => true)
          end
        end

        it 'should contain the rule' do
           shell('iptables-save') do |r|
             expect(r.stdout).to match(/-A FORWARD -p tcp -m physdev\s+--physdev-in eth0 --physdev-out eth1 -m multiport --ports 703 -m comment --comment "703 - test" -j ACCEPT/)
           end
        end
      end
    end

    #iptables version 1.3.5 is not suppored by the ip6tables provider
    if default['platform'] !~ /el-5/
      describe 'ip6tables physdev tests' do
        context 'physdev_in eth0' do
          it 'applies' do
            pp = <<-EOS
              class { '::firewall': }
              firewall { '701 - test':
                provider => 'ip6tables',
                chain => 'FORWARD',
                proto  => tcp,
                port   => '701',
                action => accept,
                physdev_in => 'eth0',
              }
            EOS

            apply_manifest(pp, :catch_failures => true)
            unless fact('selinux') == 'true'
              apply_manifest(pp, :catch_changes => true)
            end
          end

          it 'should contain the rule' do
             shell('ip6tables-save') do |r|
               expect(r.stdout).to match(/-A FORWARD -p tcp -m physdev\s+--physdev-in eth0 -m multiport --ports 701 -m comment --comment "701 - test" -j ACCEPT/)
             end
          end
        end

        context 'physdev_out eth1' do
          it 'applies' do
            pp = <<-EOS
              class { '::firewall': }
              firewall { '702 - test':
                provider => 'ip6tables',
                chain => 'FORWARD',
                proto  => tcp,
                port   => '702',
                action => accept,
                physdev_out => 'eth1',
              }
            EOS

            apply_manifest(pp, :catch_failures => true)
            unless fact('selinux') == 'true'
              apply_manifest(pp, :catch_changes => true)
            end
          end

          it 'should contain the rule' do
             shell('ip6tables-save') do |r|
               expect(r.stdout).to match(/-A FORWARD -p tcp -m physdev\s+--physdev-out eth1 -m multiport --ports 702 -m comment --comment "702 - test" -j ACCEPT/)
             end
          end
        end

        context 'physdev_in eth0 and physdev_out eth1' do
          it 'applies' do
            pp = <<-EOS
              class { '::firewall': }
              firewall { '703 - test':
                provider => 'ip6tables',
                chain => 'FORWARD',
                proto  => tcp,
                port   => '703',
                action => accept,
                physdev_in => 'eth0',
                physdev_out => 'eth1',
              }
            EOS

            apply_manifest(pp, :catch_failures => true)
            unless fact('selinux') == 'true'
              apply_manifest(pp, :catch_changes => true)
            end
          end

          it 'should contain the rule' do
             shell('ip6tables-save') do |r|
               expect(r.stdout).to match(/-A FORWARD -p tcp -m physdev\s+--physdev-in eth0 --physdev-out eth1 -m multiport --ports 703 -m comment --comment "703 - test" -j ACCEPT/)
             end
          end
        end
      end
    end

end