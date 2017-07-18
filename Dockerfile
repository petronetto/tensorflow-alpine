# MIT License

# Copyright (c) 2017 Juliano Petronetto

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

FROM alpine:3.5

ENV BAZEL_VERSION 0.4.5
ENV TENSORFLOW_VERSION 1.1.0

RUN apk add --no-cache \
        python3 \
        freetype \
        lapack \
        libgfortran \
        libpng \
        libjpeg-turbo \
        imagemagick \
        graphviz
RUN apk add --no-cache --virtual=.build-deps \
        bash \
        cmake \
        curl \
        freetype-dev \
        g++ \
        gfortran \
        lapack-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        linux-headers \
        make \
        musl-dev \
        openjdk8 \
        perl \
        python3-dev \
        rsync \
        sed \
        swig \
        zip \
    && cd /tmp \
    && $(cd /usr/include/ && ln -s locale.h xlocale.h) \
    && pip3 install --no-cache-dir numpy wheel \
    && curl -SLO https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/bazel-${BAZEL_VERSION}-dist.zip \
    && mkdir bazel-${BAZEL_VERSION} \
    && unzip -qd bazel-${BAZEL_VERSION} bazel-${BAZEL_VERSION}-dist.zip \
    && cd bazel-${BAZEL_VERSION} \
    && sed -i -e '/"-std=c++0x"/{h;s//"-fpermissive"/;x;G}' tools/cpp/cc_configure.bzl \
    && sed -i -e '/#endif  \/\/ COMPILER_MSVC/{h;s//#else/;G;s//#include <sys\/stat.h>/;G;}' third_party/ijar/common.h \
    && bash compile.sh \
    && cp -p output/bazel /usr/bin/ \
    && cd /tmp \
    && curl -SL https://github.com/tensorflow/tensorflow/archive/v${TENSORFLOW_VERSION}.tar.gz \
        | tar xzf - \
    && cd tensorflow-${TENSORFLOW_VERSION} \
    && $(cd /usr/bin && ln -s python3 python) \
    && sed -i -e '/JEMALLOC_HAVE_SECURE_GETENV/d' third_party/jemalloc.BUILD \
    && sed -i -e 's/2b7430d96aeff2bb624c8d52182ff5e4b9f7f18a/af2d5f5ad3808b38ea58c9880be1b81fd2a89278/' \
        -e 's/e5d3d4e227a0f7afb8745df049bbd4d55474b158ca5aaa2a0e31099af24be1d0/89fb700e6348a07829fac5f10133e44de80f491d1f23bcc65cba072c3b374525/' \
            tensorflow/workspace.bzl \
    && echo | PYTHON_BIN_PATH=/usr/bin/python \
                CC_OPT_FLAGS="-march=native" \
                TF_NEED_JEMALLOC=1 \
                TF_NEED_GCP=0 \
                TF_NEED_HDFS=0 \
                TF_NEED_OPENCL=0 \
                TF_NEED_CUDA=0 \
                TF_ENABLE_XLA=0 \
                bash configure \
    && bazel build -c opt --local_resources 2048,.8,1.0 //tensorflow/tools/pip_package:build_pip_package \
    && ./bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/tensorflow_pkg \
    && cd \
    && pip3 install --no-cache-dir /tmp/tensorflow_pkg/tensorflow-${TENSORFLOW_VERSION}-cp35-cp35m-linux_x86_64.whl \
    && pip3 install --no-cache-dir pandas scipy jupyter \
    && pip3 install --no-cache-dir scikit-learn matplotlib Pillow \
    && pip3 install --no-cache-dir google-api-python-client \
    && apk del .build-deps \
    && rm -f /usr/bin/bazel \
    && rm -rf /tmp/* /root/.cache

# Create nbuser user with UID=1000 and in the 'users' group
RUN adduser -G users -u 1000 -s /bin/sh -D nbuser && \
    echo "nbuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir /home/nbuser/notebooks && \
    mkdir /home/nbuser/.jupyter && \
    mkdir /home/nbuser/.local && \
    mkdir -p /home/nbuser/.ipython/profile_default/startup/ && \
    chown -Rf nbuser:users /home/nbuser

# Run notebook without token
RUN echo "c.NotebookApp.token = u''" >> /home/nbuser/.jupyter/jupyter_notebook_config.py

# Copy the file to start the container
COPY start.sh /start.sh
RUN chmod a+x /start.sh

EXPOSE 8888

WORKDIR /home/nbuser/notebooks

USER nbuser

CMD ["/start.sh"]
