%define smartmetroot /smartmet

Name:           smartmet-data-goes
Version:        17.6.30
Release:        1%{?dist}.fmi
Summary:        SmartMet Data GOES Satellite
Group:          System Environment/Base
License:        MIT
URL:            https://github.com/fmidev/smartmet-data-goes
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:      noarch

Requires:       wget
Requires:       gdal
Requires:       ImageMagick

%description
TODO

%prep

%build

%pre

%install
rm -rf $RPM_BUILD_ROOT
mkdir $RPM_BUILD_ROOT
cd $RPM_BUILD_ROOT

mkdir -p .%{smartmetroot}/cnf/cron/{cron.d,cron.hourly}
mkdir -p .%{smartmetroot}/tmp/data/goes
mkdir -p .%{smartmetroot}/editor/sat
mkdir -p .%{smartmetroot}/logs/data
mkdir -p .%{smartmetroot}/run/data/goes/bin

cat > %{buildroot}%{smartmetroot}/cnf/cron/cron.d/goes.cron <<EOF
10,40,55 * * * * /smartmet/run/data/goes/bin/dogoes.sh >& /smartmet/logs/data/goes.log
EOF

cat > %{buildroot}%{smartmetroot}/cnf/cron/cron.hourly/clean_data_goes <<EOF
#!/bin/sh
# Clean GOES data older than 7 days (7 * 24 * 60 = 10080 min)
find %{smartmetroot}/editor/sat -type f -mmin +10080 -delete
EOF

install -m 755 %_topdir/SOURCES/smartmet-data-goes/dogoes.sh %{buildroot}%{smartmetroot}/run/data/goes/bin/

%post

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,smartmet,smartmet,-)
%config(noreplace) %{smartmetroot}/cnf/cron/cron.d/goes.cron
%config(noreplace) %attr(0755,smartmet,smartmet) %{smartmetroot}/cnf/cron/cron.hourly/clean_data_goes
%{smartmetroot}/*

%changelog
* Fri Jun 30 2017 Mikko Rauhala <mikko.rauhala@fmi.fi> 17.6.30-1.el7.fmi
- Initial Version
