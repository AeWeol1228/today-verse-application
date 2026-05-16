// content.js — Static content for the prototype
// (Today's verse, history items, etc.)

window.TV_CONTENT = {
  today: {
    dateISO: '2026-05-16',
    weekday: 'Saturday',
    dateLong: 'May 16, 2026',
    dateKR: '2026년 5월 16일 토요일',
    book: { ko: '로마서', en: 'Romans', kind: 'Letter', period: 'A.D. 56–58' },
    reference: '로마서 8:28–29',
    referenceEn: 'Romans 8:28–29',
    bookDescription: [
      '로마서는 사도 바울이 로마에 있는 신자들에게 보낸 가장 정교한 신학 서신입니다.',
      '그는 로마를 직접 방문하기 전, 자신의 복음 이해를 서면으로 미리 전했습니다. 본 서신은 그가 이후의 사역에서 다루게 될 핵심 주제—믿음으로 말미암는 의(義), 죄와 은혜, 유대인과 이방인의 화해—를 차분하게 정리한 글입니다.',
      '8장은 로마서의 정점으로 불리며, "성령 안에서의 삶"과 "고난 가운데서의 소망"을 다룹니다. 28절은 그 흐름의 결론에 가까운 구절로, 우리의 모든 일이 하나님의 손 안에서 합력하여 선을 이룬다는 위로를 담고 있습니다.',
    ],
    verses: [
      {
        n: 28,
        text: '우리가 알거니와 하나님을 사랑하는 자 곧 그의 뜻대로 부르심을 입은 자들에게는 모든 것이 합력하여 선을 이루느니라',
      },
      {
        n: 29,
        text: '하나님이 미리 아신 자들을 또한 그 아들의 형상을 본받게 하기 위하여 미리 정하셨으니 이는 그로 많은 형제 중에서 맏아들이 되게 하려 하심이니라',
      },
    ],
    ttsLength: '2:18',
  },
  history: [
    { dateKR: '5월 15일 (금)', dateEn: 'May 15', book: '시편',     ref: '시편 23:1–3',    preview: '여호와는 나의 목자시니 내게 부족함이 없으리로다…' },
    { dateKR: '5월 14일 (목)', dateEn: 'May 14', book: '마태복음', ref: '마태복음 6:33',  preview: '너희는 먼저 그의 나라와 그의 의를 구하라 그리하면 이 모든 것을 너희에게 더하시리라' },
    { dateKR: '5월 13일 (수)', dateEn: 'May 13', book: '잠언',     ref: '잠언 3:5–6',    preview: '너는 마음을 다하여 여호와를 신뢰하고 네 명철을 의지하지 말라' },
    { dateKR: '5월 12일 (화)', dateEn: 'May 12', book: '빌립보서', ref: '빌립보서 4:6–7', preview: '아무 것도 염려하지 말고 다만 모든 일에 기도와 간구로…' },
    { dateKR: '5월 11일 (월)', dateEn: 'May 11', book: '이사야',   ref: '이사야 40:31',  preview: '오직 여호와를 앙망하는 자는 새 힘을 얻으리니…' },
    { dateKR: '5월 10일 (일)', dateEn: 'May 10', book: '고린도전서', ref: '고전 13:4–7', preview: '사랑은 오래 참고 사랑은 온유하며 시기하지 아니하며…' },
    { dateKR: '5월 9일 (토)',  dateEn: 'May  9', book: '요한복음', ref: '요한복음 14:27', preview: '평안을 너희에게 끼치노니 곧 나의 평안을 너희에게 주노라…' },
    { dateKR: '5월 8일 (금)',  dateEn: 'May  8', book: '시편',     ref: '시편 46:10',    preview: '너희는 가만히 있어 내가 하나님 됨을 알지어다' },
  ],
};
