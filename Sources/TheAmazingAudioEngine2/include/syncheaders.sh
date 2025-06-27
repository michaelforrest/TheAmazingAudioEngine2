find -L ../src -name '*.h' | while read -r path; do
  echo $path
  ln -s "${path}"
done
rm TheAmazingAudioEngine*.h
rm AEAudiobusInputModule.h
rm AESampleRateConverter.h
ln -s ../../TheAmazingAudioEngine2/src/TheAmazingAudioEngine.h

