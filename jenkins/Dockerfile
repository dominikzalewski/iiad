FROM jenkins/jenkins:lts
USER root
RUN apt-get update \
	&& apt-get install -y apt-transport-https ca-certificates wget software-properties-common \
	&& wget -O - https://download.docker.com/linux/debian/gpg | apt-key add - \
	&& echo "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee -a /etc/apt/sources.list.d/docker.list \
	&& apt-get update \
	&& apt-cache policy docker-ce \
	&& apt-get -y install docker-ce-cli sudo jq gettext-base \
	&& curl -L https://github.com/mikefarah/yq/releases/download/2.4.0/yq_linux_amd64 -o /usr/local/bin/yq \
	&& chmod +x /usr/local/bin/yq

RUN groupadd docker \
	&& usermod -aG docker jenkins \
	&& usermod -aG sudo jenkins

#mac workaround
RUN echo "jenkins     ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER jenkins
