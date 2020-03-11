# Copyright 2020 EPAM Systems.



# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0



# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.



# See the License for the specific language governing permissions and
# limitations under the License.

FROM openshift/jenkins-slave-base-centos7:v3.11

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
USER root
# Don't download/extract docs for nuget packages
# Don't do initially populate of package cache
# Enable nodejs and dotnet scl
ENV DOTNET_CORE_VERSION=2.0 \
    BASH_ENV=/usr/local/bin/scl_enable \
    ENV=/usr/local/bin/scl_enable \
    PROMPT_COMMAND=". /usr/local/bin/scl_enable" \
    ENABLED_COLLECTIONS="rh-nodejs8 rh-dotnet20" \
    NUGET_XMLDOC_MODE=skip \
    DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1

COPY contrib/bin/scl_enable /usr/local/bin/scl_enable

# Install
RUN yum install -y centos-release-dotnet centos-release-scl-rh
RUN yum install -y rh-dotnet20-runtime-2.0-6.el7.x86_64 rh-dotnet20-dotnet-host-2.0.7-2.el7.x86_64 \
                   rh-dotnet20-libcurl-7.47.1-1.3.el7.x86_64 rh-dotnet20-lttng-ust-2.8.1-3.el7.x86_64 \
                   rh-dotnet20-dotnet-runtime-2.0-2.0.7-2.el7.x86_64 rh-dotnet20-dotnet-2.0.7-2.el7.x86_64 \
                   rh-dotnet20-2.0-6.el7.x86_64 rh-dotnet20-userspace-rcu-0.9.2-3.el7.x86_64 \
                   rh-dotnet20-dotnet-sdk-2.0-2.0.3-4.1.el7.centos.x86_64 \
                   --setopt=tsflags=nodocs rh-dotnet20 rh-nodejs8-npm && \
                   rpm -V rh-dotnet20 rh-nodejs8-npm

RUN yum remove java-1.8.0-openjdk-headless java-1.7.0-openjdk-headless java-1.7.0-openjdk java-1.7.0-openjdk-devel -y && \
    yum -y install java-11-openjdk-devel.x86_64 && \
    yum clean all -y
# yum cache files may still exist (and quite large in size)
RUN rm -rf /var/cache/yum/*

RUN chown -R "1001:0" "$HOME" && \
    chmod -R "g+rw" "$HOME"

USER 1001