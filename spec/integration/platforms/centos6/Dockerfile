FROM centos:6

RUN rm -f /var/run/yum.pid
RUN yum clean all
RUN yum install -y yum install openssh openssh-server openssh-clients sudo passwd
RUN useradd tester
RUN echo "tester" | passwd --stdin tester
RUN mkdir -p /home/tester/.ssh; chown tester /home/tester/.ssh; chmod 700 /home/tester/.ssh
ADD authorized_keys /home/tester/.ssh/
RUN chown tester /home/tester/.ssh/authorized_keys; chmod 600 /home/tester/.ssh/authorized_keys
RUN echo "tester    ALL=(ALL)       NOPASSWD:ALL" >> /etc/sudoers.d/tester
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
RUN sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config
RUN sed -ri 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
RUN /etc/init.d/sshd start
RUN /etc/init.d/sshd stop

CMD /usr/sbin/sshd -D
