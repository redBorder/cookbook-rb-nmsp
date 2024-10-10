%global cookbook_path /var/chef/cookbooks/rb-nmsp

Name:     cookbook-rb-nmsp
Version:  %{__version}
Release:  %{__release}%{?dist}
BuildArch: noarch
Summary: nmsp cookbook to install and configure it in redborder environments

License:  GNU AGPLv3
URL:  https://github.com/redBorder/cookbook-rb-nmsp
Source0: %{name}-%{version}.tar.gz

BuildRequires: maven java-devel

Requires: java

%description
%{summary}

%global debug_package %{nil}

%prep
%setup -qn %{name}-%{version}

%build

%install
mkdir -p %{buildroot}%{cookbook_path}
mkdir -p %{buildroot}/usr/lib64/rb-nmsp

cp -f -r  resources/* %{buildroot}%{cookbook_path}
chmod -R 0755 %{buildroot}%{cookbook_path}
install -D -m 0644 README.md %{buildroot}%{cookbook_path}/README.md

%pre
if [ -d /var/chef/cookbooks/rb-nmsp ]; then
    rm -rf /var/chef/cookbooks/rb-nmsp
fi

%post
case "$1" in
  1)
    # This is an initial install.
    :
  ;;
  2)
    # This is an upgrade.
    su - -s /bin/bash -c 'source /etc/profile && rvm gemset use default && env knife cookbook upload rbnmsp'
  ;;
esac

systemctl daemon-reload

%postun
# Deletes directory when uninstall the package
if [ "$1" = 0 ] && [ -d /var/chef/cookbooks/rb-nmsp ]; then
  rm -rf /var/chef/cookbooks/rb-nmsp
fi

%files
%defattr(0755,root,root)
%{cookbook_path}
%defattr(0644,root,root)
%{cookbook_path}/README.md

%doc

%changelog
* Thu Oct 10 2024 Miguel Negrón <manegron@redborder.com>
- Add pre and postun

* Thu Sep 26 2023 Miguel Negrón <manegro@redborder.com>
- add noarch to spec file

* Fri Dec 15 2021 Eduardo Reyes <eareyes@redborder.com>
- first spec version
