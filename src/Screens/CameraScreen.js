import React, { Component } from 'react';

import {
  AppRegistry,
  View,
  Text,
  Platform,
  Image,
  TouchableOpacity
} from 'react-native';

import styles from '../Styles/Screens/CameraScreen';
import OpenCV from '../NativeModules/OpenCV';

const BorderRectangle = ({ x: left, y: top, width, height }) => (
  <View
    style={{
      borderWidth: 1,
      borderColor: '#E91E63',
      position: 'absolute',
      top,
      left,
      width: width * 0.9,
      height,
      backgroundColor: 'transparent'
    }}
  >
    <Text style={styles.label}>Pham Thanh Tu</Text>
  </View>
);

export default class CameraScreen extends Component {
  state = {
    faceRects: [],
    photoPath:
      'https://agiletechvn.github.io/wp-content/uploads/2017/12/Tu-Pham-Thanh-350x350.jpg'
  };

  componentDidMount() {
    this.processPhoto();
  }

  async processPhoto() {
    const faceRects = await OpenCV.detect(this.state.photoPath);
    this.setState({ faceRects });
  }

  render() {
    const { faceRects, photoPath } = this.state;
    return (
      <View style={styles.container}>
        <Image
          source={{
            uri: photoPath
          }}
          style={styles.imagePreview}
        />
        {faceRects.map((faceRect, index) => (
          <BorderRectangle key={index} {...faceRect} />
        ))}
      </View>
    );
  }
}

AppRegistry.registerComponent('CameraScreen', () => CameraScreen);
