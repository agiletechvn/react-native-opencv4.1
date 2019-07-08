OPENCV_VERSION=${1:-3.4.1}

# ios

wget https://sourceforge.net/projects/opencvlibrary/files/opencv-ios/${OPENCV_VERSION}/opencv-${OPENCV_VERSION}-ios-framework.zip
unzip -a opencv-${OPENCV_VERSION}-ios-framework.zip
cd ios
cp -r ./../opencv2.framework ./
cd ..
rm -rf opencv-${OPENCV_VERSION}-ios-framework.zip
rm -rf opencv2.framework/

# android

wget https://sourceforge.net/projects/opencvlibrary/files/opencv-android/${OPENCV_VERSION}/opencv-${OPENCV_VERSION}-android-sdk.zip
unzip opencv-${OPENCV_VERSION}-android-sdk.zip
cd android/app/src/main
mkdir jniLibs
cp -r ./../../../../OpenCV-android-sdk/sdk/native/libs/ ./jniLibs
cd ../../../../
rm -rf opencv-${OPENCV_VERSION}-android-sdk.zip
rm -rf OpenCV-android-sdk/

