class SoundConstants {
  static const Map<String, String> soundFileMap = {
    "Good Morning(LG)": "1_Good Morning(LG).mp3",
    "일어나셔야 합니다": "2_일어나셔야 합니다.mp3",
    "LG 굿모닝 락드럼 버전": "3_LG 굿모닝 락드럼 버전.mp3",
    "공군 훈련소 기상송 저벅가": "4_공군 훈련소 기상송 저벅가.mp3",
    "짱구는 못말려 오프닝 오리지널": "5_짱구는 못말려 오프닝 오리지널.mp3",
    "군대 기상 나팔": "6_군대 기상 나팔.mp3",
    "이마트송": "7_이마트송.mp3",
    "김수미 할머니(욕설 주의)": "8_김수미 할머니(욕설 주의).mp3",
    "카니 일어나!!!!!": "9_카니 일어나!!!!!.mp3",
    "닭 울음소리": "10_닭 울음소리.mp3",
    "사랑을 끌어오는 주파수": "11_사랑을 끌어오는 주파수.mp3",
    "각성음악(베타파, 감마파)": "12_각성음악(베타파, 감마파).mp3",
    "인강 강사들 공부자극 모음": "13_인강 강사들 공부자극 모음.mp3",
    "자연의 소리": "14_자연의 소리.mp3",
    "카이스트 거위": "15_카이스트 거위.mp3",
  };

  static const String customRecordingKey = "직접 녹음하기";

  static const String myAudioKey = "내 오디오 가져오기";

  static List<String> get soundOptions => [
    customRecordingKey,
    myAudioKey,
    ...soundFileMap.keys,
  ];
}
