class SoundConstants {
  static const Map<String, String> soundFileMap = {
    "엘지 굿모닝송": "1.mp3",
    "일어나셔야 합니다": "2.mp3",
    "군대 기상 나팔": "3.mp3",
    "이성을 끌어당기는 주파수": "4.mp3",
    "성적이 오르는 주파수": "5.mp3",
    "일어나는 건 박수받아 마땅함": "6.mp3",
  };

  static const String customRecordingKey = "직접 녹음하기";
  
  static const String myAudioKey = "내 오디오 가져오기";

  static List<String> get soundOptions => [
        ...soundFileMap.keys,
        customRecordingKey,
        myAudioKey,
      ];
}
