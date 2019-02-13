FROM ubuntu:17.10

MAINTAINER Jonathan DA ROS

ENV ANDROID_HOME="/opt/android-sdk" \
# Get the latest version from https://developer.android.com/studio/index.html
    ANDROID_SDK_TOOLS_VERSION="3859397" \
# nodejs version
    NODE_VERSION="8.x" \
# Set locale
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US.UTF-8" \
    LC_ALL="en_US.UTF-8" \
    DEBIAN_FRONTEND="noninteractive" \
    ANDROID_SDK_HOME="$ANDROID_HOME" \
    PATH="$PATH:$ANDROID_SDK_HOME/tools:$ANDROID_SDK_HOME/platform-tools" \
    JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/ \
    TERM=dumb \
    DEBIAN_FRONTEND=noninteractive


COPY README.md /README.md

WORKDIR /tmp

# Installing packages
RUN apt-get update -qq > /dev/null && \
    apt-get install -qq locales > /dev/null && \
    locale-gen "$LANG" > /dev/null && \
    apt-get install -qq --no-install-recommends \
        build-essential \
        autoconf \
        curl \
        git \
        lib32stdc++6 \
        lib32z1 \
        lib32z1-dev \
        lib32ncurses5 \
        libc6-dev \
        libgmp-dev \
        libmpc-dev \
        libmpfr-dev \
        libxslt-dev \
        libxml2-dev \
        m4 \
        ncurses-dev \
        ocaml \
        openjdk-8-jdk \
        openssh-client \
        pkg-config \
        python-software-properties \
        ruby-full \
        software-properties-common \
        unzip \
        wget \
        zip \
	swig \
        zlib1g-dev > /dev/null && \
    echo "installing nodejs, npm, cordova, ionic, react-native" && \
    curl -sL -k https://deb.nodesource.com/setup_${NODE_VERSION} \
        | bash - > /dev/null && \
    apt-get install -qq nodejs > /dev/null && \
    apt-get clean > /dev/null && \
    rm -rf /var/lib/apt/lists/ && \
    npm install --quiet -g npm > /dev/null && \
    npm install --quiet -g \
        bower cordova eslint gulp \
        ionic jshint karma-cli mocha \
        node-gyp npm-check-updates \
        react-native-cli > /dev/null && \
    npm cache clean --force > /dev/null && \
    rm -rf /tmp/* /var/tmp/* && \
    echo "installing fastlane" && \
    gem install fastlane --quiet --no-document > /dev/null

# Install Android SDK
RUN echo "installing sdk tools" && \
    wget --quiet --output-document=sdk-tools.zip \
        "https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_TOOLS_VERSION}.zip" && \
    mkdir --parents "$ANDROID_HOME" && \
    unzip -q sdk-tools.zip -d "$ANDROID_HOME" && \
    rm --force sdk-tools.zip && \
# Install SDKs
# Please keep these in descending order!
# The `yes` is for accepting all non-standard tool licenses.
    mkdir --parents "$HOME/.android/" && \
    echo '### User Sources for Android SDK Manager' > \
        "$HOME/.android/repositories.cfg" && \
    yes | "$ANDROID_HOME"/tools/bin/sdkmanager --licenses > /dev/null && \
    echo "installing platforms" && \
    yes | "$ANDROID_HOME"/tools/bin/sdkmanager \
        "platforms;android-26" \
        "platforms;android-25" \
        "platforms;android-24" \
        "platforms;android-23" \
        "platforms;android-22" \
        "platforms;android-21" \
        "platforms;android-20" \
        "platforms;android-19" \
        "platforms;android-18" \
        "platforms;android-17" \
        "platforms;android-16" && \
    echo "installing platform tools " && \
    yes | "$ANDROID_HOME"/tools/bin/sdkmanager \
        "platform-tools" && \
    echo "installing build tools " && \
    yes | "$ANDROID_HOME"/tools/bin/sdkmanager \
        "build-tools;26.0.2" \
		"build-tools;26.0.1" \
		"build-tools;26.0.0" && \
    echo "installing extras " && \
    yes | "$ANDROID_HOME"/tools/bin/sdkmanager \
        "extras;android;m2repository" \
        "extras;google;m2repository" && \
    echo "installing play services " && \
    yes | "$ANDROID_HOME"/tools/bin/sdkmanager \
        "extras;google;google_play_services" \
        "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2" \
        "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.1" && \
    echo "installing Google APIs" && \
    yes | "$ANDROID_HOME"/tools/bin/sdkmanager \
        "add-ons;addon-google_apis-google-24" \
        "add-ons;addon-google_apis-google-23" \
        "add-ons;addon-google_apis-google-22" \
        "add-ons;addon-google_apis-google-21" \
        "add-ons;addon-google_apis-google-19" \
        "add-ons;addon-google_apis-google-18" \
        "add-ons;addon-google_apis-google-17" \
        "add-ons;addon-google_apis-google-16" && \
    echo "installing emulator " && \
    yes | "$ANDROID_HOME"/tools/bin/sdkmanager "emulator" && \
    echo "installing system image with android 25 and google apis" && \
    yes | "$ANDROID_HOME"/tools/bin/sdkmanager \
        "system-images;android-25;google_apis;x86_64"

