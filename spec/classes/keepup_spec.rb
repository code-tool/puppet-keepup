# frozen_string_literal: true

require 'spec_helper'

describe 'keepup' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts
      end

      let(:params) do
        {}
      end

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_class('keepup::config') }
      it { is_expected.to contain_class('keepup::install') }
      it { is_expected.to contain_class('keepup::params') }

      it {
        is_expected.to contain_file('/opt/keepup').with(
          {
            ensure: 'directory',
            owner: 'root',
            group: 'root',
            mode: '0750',
          },
        )
      }

      it {
        is_expected.to contain_file('/opt/keepup/data.json').with(
          {
            ensure: 'absent',
            require: 'File[/opt/keepup]'
          },
        )
      }

      it {
        is_expected.to contain_file('/opt/keepup/pkg.json').with(
          {
            ensure: 'file',
            owner: 'root',
            group: 'root',
            mode: '0640',
            content: File.read(File.expand_path("../../fixtures/files//opt/keepup/pkg-defaults-#{facts[:os]['distro']['id']}-#{facts[:os]['distro']['release']['major']}.json", __FILE__)),
            replace: true,
          },
        )
      }

      it {
        is_expected.to contain_file('/opt/keepup/run.sh').with(
          {
            ensure: 'file',
            owner: 'root',
            group: 'root',
            mode: '0750',
            content: File.read(File.expand_path('../../fixtures/files/opt/keepup/run.sh', __FILE__)),
          },
        )
      }

      it {
        is_expected.to contain_exec('keepup-systemd-daemon-reload').with(
          {
            command: '/bin/systemctl daemon-reload',
            refreshonly: true
          },
        )
      }

      it {
        is_expected.to contain_exec('keepup-systemd-disable-timer').with(
          {
            command: '/bin/systemctl disable --now keepup.timer',
            onlyif: '/bin/systemctl list-unit-files keepup.timer --no-legend | /bin/grep -q "^keepup.timer"'
          },
        )
      }

      context 'with manage_package=true' do
        let(:params) do
          super().merge(
            manage_package: true,
          )
        end

        it { is_expected.to compile.with_all_deps }

        it {
          is_expected.to contain_package('curl').with(
            'ensure' => 'installed',
          )
        }
      end

      context 'with use_defaults=false' do
        let(:params) do
          super().merge(
            use_defaults: false,
          )
        end

        it { is_expected.to compile.with_all_deps }

        it {
          is_expected.to contain_file('/opt/keepup/pkg.json').with(
            {
              ensure: 'file',
              owner: 'root',
              group: 'root',
              mode: '0640',
              content: File.read(File.expand_path('../../fixtures/files//opt/keepup/pkg-no-defaults.json', __FILE__)),
              replace: true,
            },
          )
        }
      end

      context 'with systemd_timer=true' do
        let(:params) do
          super().merge(
            systemd_timer: true,
          )
        end

        it { is_expected.to compile.with_all_deps }

        it {
          is_expected.to contain_file('/etc/cron.d/keepup').with({ ensure: 'absent' })
        }

        it {
          is_expected.to contain_file('/etc/systemd/system/keepup.service').with(
            {
              ensure: 'file',
              owner: 'root',
              group: 'root',
              mode: '0644',
              content: File.read(File.expand_path('../../fixtures/files/etc/systemd/system/keepup.service', __FILE__)),
              notify: 'Exec[keepup-systemd-daemon-reload]'
            },
          )
        }

        it {
          is_expected.to contain_file('/etc/systemd/system/keepup.timer').with(
            {
              ensure: 'file',
              owner: 'root',
              group: 'root',
              mode: '0644',
              content: File.read(File.expand_path('../../fixtures/files/etc/systemd/system/keepup.timer', __FILE__)),
              notify: 'Exec[keepup-systemd-daemon-reload]'
            },
          )
        }

        it {
          is_expected.to contain_service('keepup.timer').with(
            {
              ensure: 'running',
              enable: true,
              require: 'Exec[keepup-systemd-daemon-reload]',
              subscribe: 'File[/etc/systemd/system/keepup.timer]'
            },
          )
        }
      end

      context 'with config_manage=false' do
        let(:params) do
          super().merge(
            config_manage: false,
          )
        end

        it { is_expected.to compile.with_all_deps }

        it {
          is_expected.to contain_file('/opt/keepup/pkg.json').with({ ensure: 'absent' })
          is_expected.to contain_file('/opt/keepup/run.sh').with({ ensure: 'absent' })
          is_expected.to contain_file('/etc/cron.d/keepup').with({ ensure: 'absent' })
          is_expected.to contain_file('/etc/systemd/system/keepup.service').with({ ensure: 'absent' })
          is_expected.to contain_file('/etc/systemd/system/keepup.timer').with({ ensure: 'absent' })
        }
      end
    end
  end
end
