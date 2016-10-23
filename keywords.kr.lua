--if GetLocale() ~= "koKR" then return end
-------------------------------------------
-- 최종수정 : 2013/10/01 11:18

-- 각종 필터링 정보를 담고 있는 파일입니다.
-- 패치로 새로운 던전이 추가되거나 난이도가 추가될 경우 이 파일에서 수정하시면 됩니다.
-- 난이도 추가시에는 FindParty.lua 파일에서 별도 처리가 필요할 수도 있습니다.

-- ===============================
-- 난이도 분류 키워드를 정의합니다.
-- dbname은 실제로 애드온에서 인식하는 명칭이며, name은 애드온에서 표시되는 부분입니다.
-- postfix를 입력할 경우 던전 이름 뒤에 입력한 글자가 추가로 표시됩니다.
-- color은 선택한 난이도를 어떤 색상으로 표시할지 정의하는 부분입니다.
-- keywords는 파티모집 문구에 해당 문자열이 있을 경우 해당 난이도로 분류할 수 있도록 정의하는 부분입니다.
-- 10인, 25인, 영웅 난이도는 별도로 처리 합니다.
FP_DIFFICULTY_KEYWORDS = {
	[1] = {
		name = "신화",
		dbname = "mythic",
		postfix = "|cffff0000 (M)",
		color = {0.7, 0, 0.7},
		keywords = {"신화","신던"},
	},
	[2] = {
		name = "영웅",
		dbname = "heroic",
		postfix = "|cffff0000 (H)",
		color = {0.5, 0.5, 0.8},
		keywords = {"영웅", "영던", "0던", "하드"},
	},
	[3] = {
		name = "일반",
		dbname = "normal",
		postfix = "",
		color = {1, 1, 1},
		keywords = {"일반", "일던", "탄공"},
	},
	[4] = {
		name = "공격대 찾기",
		dbname = "25lfr",
		postfix = " (L)",
		color = {0.2, 0.6, 0.8},
		keywords = {"무작", "공찾", "공격대찾기"},
	},
	[5] = {
		name = "도전 모드",
		dbname = "challenge",
		postfix = "|cffff0000 (C)",
		color = {0, 1, 1},
		keywords = {"도전", "금메달"},
	},
	[6] = {
		name = "10인",
		dbname = "10normal",
		postfix = " (10)",
		color = {0, 1, 0},
		keywords = {"10", "1특", "1직"},
	},
	[7] = {
		name = "25인",
		dbname = "25normal",
		postfix = " (25)",
		color = {1.0, 0.7, 0},
		keywords = {"25", "2직"},
	},
	[8] = {
		name = "10인 영웅",
		dbname = "10heroic",
		postfix = "|cffff0000 (10H)",
		color = {0, 1, 0.7},
		keywords = {},
	},
	[9] = {
		name = "25인 영웅",
		dbname = "25heroic",
		postfix = "|cffff0000 (25H)",
		color = {1.0, 0.7, 0.7},
		keywords = {},
	},
}

-- ==============================
-- 던전 분류 키워드를 정의합니다.
-- 아래 모든 필드가 있어야합니다.
-- category는 새로운 분류를 추가할 때 이용하시면 됩니다.
-- name은 던전 이름을 입력하며, 낮은 번호가 우선으로 인식됩니다. 번호가 중복되지 않도록 하여주시기 바랍니다.
-- difficulty는 해당 던전에 존재하는 난이도를 정의하는 부분입니다. 난이도 정의의 dbname에 맞게 입력하셔야 합니다.
-- keywords는 파티모집 문구에 해당 문자열이 있을 경우 해당 난이도로 분류할 수 있도록 정의하는 부분입니다.
-- heroickeywods는 던전 분류후 해당 문자열이 발견될 경우 영웅 난이도로 분류하도록 별도로 정의하는 부분입니다. 
-- 시네스트라나 비룡팟등 기본 하드 진행인데, 하드로 분류되지 않는 경우를 대비하여 만들어 졌습니다. 하드 난이도에만 존재하는 네임드의 경우, 이 곳에 키워드를 적을 수 있습니다.
-- 단, 이 경우 던전 분류시 인식하지 않으므로 던전 분류에서 해당 키워드를 기재하여 우선 던전을 인식시키는 작업이 필요합니다. (황혼의 요새를 참고하시기 바랍니다.)
FP_DUNGEON_KEYWORDS = {
	[1] = {
		category = "드레노어의 전쟁군주 공격대",
		dungeon = {
			[1] = {
				name = "검은바위 용광로",
				difficulty = {"normal", "heroic", "25lfr", "mythic"},
				keywords = {"용광", "검용", "주조장"},
				excludekeywords = {"피의용광로"},
			},
			[2] = {
				name = "높은망치",
				difficulty = {"normal", "heroic", "25lfr", "mythic"},
				keywords = {"높망", "오름", "망치"},
				excludekeywords = {"피망치"},
			},
			[3] = {
				name = "루크마르",
				difficulty = {"normal"},
				keywords = {"루크"},
			},
			[4] = {
				name = "파괴의 현신 드로브",
				difficulty = {"normal"},
				keywords = {"현신", "드로브"},
			},
			[5] = {
				name = "영생의 탈르나",
				difficulty = {"normal"},
				keywords = {"탈르나", "영생"},
			},
			[6] = {
				name = "지옥불 성채",
				difficulty = {"normal", "heroic", "25lfr", "mythic"},
				keywords = {"지옥불", "성채"},
			},
			[7] = {
				name = "카자크",
				difficulty = {"normal"},
				keywords = {"카자크"},
			}
		},
	},
	[2] = {
		category = "드레노어의 전쟁군주 던전",
		dungeon = {
			[1] = {
				name = "무작위 도전모드",
				difficulty = {"challenge"},
				keywords = {"도전모드"},
				excludekeywords = {"일퀘"},
			},
			[2] = {
				name = "무작위 5인 던전",
				difficulty = {"heroic", "normal"},
				keywords = {"랜덤", "랜영", "무작던전", "무작영던", "영던스핀", "무작스핀"},
				heroickeywords = {"랜영", "무작영던", "영던스핀", "무작스핀"},
			},
			[3] = {
				name = "강철 선착장",
				difficulty = {"heroic", "challenge", "normal"},
				keywords = {"강철", "선착"},
			},
			[4] = {
				name = "검은바위 첨탑 상층",
				difficulty = {"heroic", "challenge", "normal"},
				keywords = {"상층", "리로이"},
			},
			[5] = {
				name = "상록숲",
				difficulty = {"heroic", "challenge", "normal"},
				keywords = {"상록"},
			},
			[6] = {
				name = "아킨둔",
				difficulty = {"heroic", "challenge", "normal"},
				keywords = {"아킨"},
			},
			[7] = {
				name = "어둠달 지하묘지",
				difficulty = {"heroic", "challenge", "normal"},
				keywords = {"묘지", "어묘"},
			},
			[8] = {
				name = "파멸철로 정비소",
				difficulty = {"heroic", "challenge", "normal"},
				keywords = {"정비", "파멸", "파철", "파정", "열차", "설국"},
			},
			[9] = {
				name = "피망치 잿가루 광산",
				difficulty = {"heroic", "challenge", "normal"},
				keywords = {"광산", "잿가루", "피망", "크로만"},
			},
			[10] = {
				name = "하늘탑",
				difficulty = {"heroic", "challenge", "normal"},
				keywords = {"하늘"},
			},
		},
	},
	[3] = {
		category = "판다리아의 안개 공격대",
		dungeon = {
			[1] = {
				name = "오그리마 공성전",
				difficulty = {"normal", "heroic", "25lfr", "mythic"},
				keywords = {"오공", "오그", "공성", "가로쉬"},
			},
			[2] = {
				name = "천둥의 왕좌",
				difficulty = {"10normal", "25normal", "10heroic", "25heroic", "25lfr"},
				keywords = {"천둥", "천왕", "레이션"},
				heroickeywords = {"라덴"},
				excludekeywords = {"천둥왕의용사"},
			},
			[3] = {
				name = "영원한 봄의 정원",
				difficulty = {"10normal", "25normal", "10heroic", "25heroic", "25lfr"},
				keywords = {"옛날옛적"},
				excludekeywords = {"영원의샘", "영원의눈"},
			},
			[4] = {
				name = "공포의 심장",
				difficulty = {"10normal", "25normal", "10heroic", "25heroic", "25lfr"},
				keywords = {"공심", "공포"},
			},
			[5] = {
				name = "모구샨 금고",
				difficulty = {"10normal", "25normal", "10heroic", "25heroic", "25lfr"},
				keywords = {"모구", "모규", "모금", "모쿠"},
				excludekeywords = {"모구샨궁전", "모구산궁전", "모구샨도전"},
			},
			[6] = {
				name = "오르도스",
				difficulty = {"normal"},
				keywords = {"오르", "오르도스", "오도"},--오르 손 오르도스 손 때문에 중복 등록
			},
			[7] = {
				name = "네 천신",
				difficulty = {"normal"},
				keywords = {"천신", "츠지", "위론", "흑우", "백호", "쉬엔"},--니우짜오는 키워드 중복 문제로 제외합니다.
			},
			[8] = {
				name = "운다스타",
				difficulty = {"normal"},
				keywords = {"운다", "운다스타"},-- 마찬가지로 운다 손 운다스타 손 중복 등록
			},
			[9] = {
				name = "나락크",
				difficulty = {"normal"},
				keywords = {"나락", "나락크", "나라크"},-- 운다스타와 동일
			},
			[10] = {
				name = "갈레온",
				difficulty = {"normal"},
				keywords = {"갈레", "갈레온", "갈리온", "갈레기"},
			},
			[11] = {
				name = "분노의 샤",
				difficulty = {"normal"},
				keywords = {"분샤"},
				excludekeywords = {"샤녹"},
			},
		},
	},
	[4] = {
		category = "판다리아의 안개 던전",
		dungeon = {
			[1] = {
				name = "무작위 영웅 시나리오",
				difficulty = {"heroic"},
				keywords = {"시나리오", "영웅시", "영시", "영던시"},
			},
			[2] = {
				name = "니우짜오 사원 공성전투",
				difficulty = {"heroic", "challenge", "normal"},
				keywords = {"니우짜오", "니우"},
			},
			[3] = {
				name = "석양문",
				difficulty = {"heroic", "challenge", "normal"},
				keywords = {"석양"},
			},
			[4] = {
				name = "붉은십자군 수도원",
				difficulty = {"heroic", "challenge", "normal"},
				keywords = {"수도원"},
				excludekeywords = {"음영파수도원"},
			},
			[5] = {
				name = "붉은십자군 전당",
				difficulty = {"heroic", "challenge", "normal"},
				keywords = {"그냥가지마"},
			},
			[6] = {
				name = "스칼로맨스",
				difficulty = {"heroic", "challenge", "normal"},
				keywords = {"스칼"},
			},
			[7] = {
				name = "모구샨 궁전",
				difficulty = {"heroic", "challenge", "normal"},
				keywords = {"모구샨궁전", "모구산 궁전"},
			},
			[8] = {
				name = "음영파 수도원",
				difficulty = {"heroic", "challenge", "normal"},
				keywords = {"음영파"},
			},
			[9] = {
				name = "스톰스타우트 양조장",
				difficulty = {"heroic", "challenge", "normal"},
				keywords = {"판다렌스톰스타우트양조"},
			},
			[10] = {
				name = "옥룡사",
				difficulty = {"heroic", "challenge", "normal"},
				keywords = {"옥룡"},
			},
		},
	},
	[5] = {
		category = "대격변 공격대",
		dungeon = {
			[1] = {
				name = "용의 영혼",
				difficulty = {"10normal", "25normal", "10heroic", "25heroic", "25lfr"},
				keywords = {"용영", "데스윙", "용의영혼"},
			},
			[2] = {
				name = "바라딘 요새",
				difficulty = {"10normal", "25normal"},
				keywords = {"바라딘", "톨바"},
			},
			[3] = {
				name = "불의 땅",
				difficulty = {"10normal", "25normal", "10heroic", "25heroic"},
				keywords = {"불땅", "불의땅", "라그", "대표단"},
			},
			[4] = {
				name = "검은날개 강림지",
				difficulty = {"10normal", "25normal", "10heroic", "25heroic"},
				keywords = {"강림지", "검날", "검은날개", "검강", "네파"},
			},
			[5] = {
				name = "황혼의 요새",
				difficulty = {"10normal", "25normal", "10heroic", "25heroic"},
				keywords = {"황혼", "황요", "초갈", "시네"},
				heroickeywords = {"시네"},
			},
			[6] = {
				name = "네 바람의 왕좌",
				difficulty = {"10normal", "25normal", "10heroic", "25heroic"},
				keywords = {"네바람", "알아키르"},
			},
		},
	},
	[6] = {
		category = "대격변 던전",
		dungeon = {
			[1] = {
				name = "시간의 끝",
				difficulty = {"heroic"},
				keywords = {"시간의", "시끝"},
			},
			[2] = {
				name = "영원의 샘",
				difficulty = {"heroic"},
				keywords = {"영샘", "영원의"},
				excludekeywords = {"영원의눈"},
			},
			[3] = {
				name = "황혼의 시간",
				difficulty = {"heroic"},
				keywords = {"황혼의시간", "황시"},
			},
			[4] = {
				name = "줄구룹",
				difficulty = {"heroic"},
				keywords = {"줄굽", "줄구", "즐구"},
			},
			[5] = {
				name = "줄아만",
				difficulty = {"heroic"},
				keywords = {"줄아", "공물"},
			},
			[6] = {
				name = "검은바위 동굴",
				difficulty = {"heroic", "normal"},
				keywords = {"검바", "동굴"},
			},
			[7] = {
				name = "그림 바톨",
				difficulty = {"heroic", "normal"},
				keywords = {"그바", "바툴", "바톨"},
			},
			[8] = {
				name = "바위 심장부",
				difficulty = {"heroic", "normal"},
				keywords = {"바심", "바위심장"},
			},
			[9] = {
				name = "시초의 전당",
				difficulty = {"heroic", "normal"},
				keywords = {"시초"},
			},
			[10] = {
				name = "톨비르의 잃어버린 도시",
				difficulty = {"heroic", "normal"},
				keywords = {"톨비르"},
			},
			[11] = {
				name = "파도의 왕좌",
				difficulty = {"heroic", "normal"},
				keywords = {"파도", "파왕", "왕좌"},
			},
			[12] = {
				name = "그림자송곳니 성채",
				difficulty = {"heroic", "normal"},
				keywords = {"그림자", "성채", "송곳니", "그송"},
			},
			[13] = {
				name = "죽음의 폐광",
				difficulty = {"heroic", "normal"},
				keywords = {"폐광"},
			},
		},
	},
	[7] = {
		category = "리치왕의 분노 공격대",
		dungeon = {
			[1] = {
				name = "얼음왕관 성채",
				difficulty = {"10normal", "25normal", "10heroic", "25heroic"},
				keywords = {"얼음왕관", "얼왕", "얼성"},
			},
			[2] = {
				name = "루비 성소",
				difficulty = {"10normal", "25normal", "10heroic", "25heroic"},
				keywords = {"루비", "할리"},
			},
			[3] = {
				name = "아카본 석실",
				difficulty = {"10normal", "25normal"},
				keywords = {"아카본"},
			},
			[4] = {
				name = "십자군의 시험장",
				difficulty = {"10normal", "25normal", "10heroic", "25heroic"},
				keywords = {"십자", "아눕"},
			},
			[5] = {
				name = "오닉시아의 둥지",
				difficulty = {"10normal", "25normal"},
				keywords = {"오닉"},
			},
			[6] = {
				name = "울두아르",
				difficulty = {"10normal", "25normal", "10heroic", "25heroic"},
				keywords = {"울두", "울드", "알갈", "요그", "미미"},
				heroickeywords = {"비룡", "미미"},
			},
			[7] = {
				name = "흑요석 성소",
				difficulty = {"10normal", "25normal", "10heroic", "25heroic"},
				keywords = {"흑요", "살타"},
				heroickeywords = {"비룡"},
			},
			[8] = {
				name = "영원의 눈",
				difficulty = {"10normal", "25normal"},
				keywords = {"영원의눈", "영눈", "말리"},
			},
			[9] = {
				name = "낙스라마스",
				difficulty = {"10normal", "25normal"},
				keywords = {"낙스", "켈투"},
			},
		},
	},
	[8] = {
		category = "리치왕의 분노 던전",
		dungeon = {
			[1] = {
				name = "영혼의 제련소",
				difficulty = {"heroic", "normal"},
				keywords = {"제련", "제련소", "영제"},
			},
			[2] = {
				name = "사론의 구덩이",
				difficulty = {"heroic", "normal"},
				keywords = {"사론", "샤론"},
			},
			[3] = {
				name = "투영의 전당",
				difficulty = {"heroic", "normal"},
				keywords = {"투영"},
			},
			[4] = {
				name = "용사의 시험장",
				difficulty = {"heroic", "normal"},
				keywords = {"용사", "마상"},
				excludekeywords = {"천둥왕의용사"},
			},
			[5] = {
				name = "군드락",
				difficulty = {"heroic", "normal"},
				keywords = {"군드"},
			},
			[6] = {
				name = "돌의 전당",
				difficulty = {"heroic", "normal"},
				keywords = {"돌전", "돌의"},
			},
			[7] = {
				name = "드락타론 성채",
				difficulty = {"heroic", "normal"},
				keywords = {"드락타론"},
			},
			[8] = {
				name = "마력의 눈",
				difficulty = {"heroic", "normal"},
				keywords = {"마눈", "마력의눈"},
			},
			[9] = {
				name = "마력의 탑",
				difficulty = {"heroic", "normal"},
				keywords = {"마탑","마력의탑"},
			},
			[10] = {
				name = "번개의 전당",
				difficulty = {"heroic", "normal"},
				keywords = {"번개", "번전"},
			},
			[11] = {
				name = "보랏빛 요새",
				difficulty = {"heroic", "normal"},
				keywords = {"그런건없다"},
			},
			[12] = {
				name = "아졸네룹",
				difficulty = {"heroic", "normal"},
				keywords = {"아졸"},
			},
			[13] = {
				name = "안카헤트: 고대 왕국",
				difficulty = {"heroic", "normal"},
				keywords = {"안카", "앙카"},
			},
			[14] = {
				name = "옛 스트라솔름",
				difficulty = {"heroic", "normal"},
				keywords = {"옛솔", "솔름", "솔룸"},
			},
			[15] = {
				name = "우트가드 성채",
				difficulty = {"heroic", "normal"},
				keywords = {"우트가드", "우트성채"},
			},
			[16] = {
				name = "우트가드 첨탑",
				difficulty = {"heroic", "normal"},
				keywords = {"우트가드첨탑", "우트첨탑"},
			},
		},
	},
	[9] = {
		category = "불타는 성전 공격대",
		dungeon = {
			[1] = {
				name = "태양샘 고원",
				difficulty = {"normal"},
				keywords = {"태샘", "양샘", "킬제덴", "소리달"},
			},
			[2] = {
				name = "검은 사원",
				difficulty = {"normal"},
				keywords = {"검사", "일리단", "아지", "검은사원"},
			},
			[3] = {
				name = "하이잘 정상",
				difficulty = {"normal"},
				keywords = {"하이잘"},
			},
			[4] = {
				name = "폭풍우 요새",
				difficulty = {"normal"},
				keywords = {"폭풍우", "폭우", "폭요", "캘타", "켈타", "알라르"},
			},
			[5] = {
				name = "불뱀 제단",
				difficulty = {"normal"},
				keywords = {"불뱀", "잠복", "바쉬"},
			},
			[6] = {
				name = "그룰의 등지",
				difficulty = {"normal"},
				keywords = {"그룰", "그롤", "마울"},
			},
			[7] = {
				name = "마그테리돈의 둥지",
				difficulty = {"normal"},
				keywords = {"마그"},
			},
			[8] = {
				name = "카라잔",
				difficulty = {"normal"},
				keywords = {"나나난나나나나나나나나난"},
			},
		},
	},
	[10] = {
		category = "불타는 성전 던전",
		dungeon = {
			[1] = {
				name = "마법학자의 정원",
				difficulty = {"heroic", "normal"},
				keywords = {"마법학자", "마정", "정원", "매타조"},
			},
			[2] = {
				name = "메카나르",
				difficulty = {"heroic", "normal"},
				keywords = {"메카"},
			},
			[3] = {
				name = "알카트라즈",
				difficulty = {"heroic", "normal"},
				keywords = {"알카"},
			},
			[4] = {
				name = "신록의 정원",
				difficulty = {"heroic", "normal"},
				keywords = {"신록"},
			},
			[5] = {
				name = "어둠의 미궁",
				difficulty = {"heroic", "normal"},
				keywords = {"미궁"},
			},
			[6] = {
				name = "세데크 전당",
				difficulty = {"heroic", "normal"},
				keywords = {"세데크", "세덱", "안주"},
			},
			[7] = {
				name = "아키나이 납골당",
				difficulty = {"heroic", "normal"},
				keywords = {"납골"},
			},
			[8] = {
				name = "마나 무덤",
				difficulty = {"heroic", "normal"},
				keywords = {"마나"},
			},
			[9] = {
				name = "증기 저장고",
				difficulty = {"heroic", "normal"},
				keywords = {"증기"},
			},
			[10] = {
				name = "지하 수렁",
				difficulty = {"heroic", "normal"},
				keywords = {"수렁"},
			},
			[11] = {
				name = "강제 노역소",
				difficulty = {"heroic", "normal"},
				keywords = {"노역"},
			},
			[12] = {
				name = "으스러진 손의 전당",
				difficulty = {"heroic", "normal"},
				keywords = {"으스", "으손"},
			},
			[13] = {
				name = "피의 용광로",
				difficulty = {"heroic", "normal"},
				keywords = {"피용"},
			},
			[14] = {
				name = "지옥불 성루",
				difficulty = {"heroic", "normal"},
				keywords = {"성루"},
			},		
			[15] = {
				name = "검은 늪",
				difficulty = {"heroic", "normal"},
				keywords = {"검은늪", "검늪"},
			},		
			[16] = {
				name = "옛 언덕마루 구릉지",
				difficulty = {"heroic", "normal"},
				keywords = {"옛언덕", "옛힐", "힐스"},
			},
		},
	},
	[11] = {
		category = "오리지널 공격대",
		dungeon = {
			[1] = {
				name = "안퀴라즈 사원",
				difficulty = {"normal"},
				keywords = {"안퀴", "사원", "쑨", "크툰"},
			},
			[2] = {
				name = "안퀴라즈 폐허",
				difficulty = {"normal"},
				keywords = {"폐허"},
			},
			[3] = {
				name = "검은날개 둥지",
				difficulty = {"normal"},
				keywords = {"검둥"},
			},
			[4] = {
				name = "화산 심장부",
				difficulty = {"normal"},
				keywords = {"화산", "화심"},
			},
		},
	},
	[12] = {
		category = "오리지널 던전",
		dungeon = {
			[1] = {
				name = "가라앉은 사원",
				difficulty = {"normal"},
				keywords = {"가라앉은", "학카르"},
			},
			[2] = {
				name = "가시덩굴 구릉",
				difficulty = {"normal"},
				keywords = {"구릉"},
			},
			[3] = {
				name = "가시덩굴 우리",
				difficulty = {"normal"},
				keywords = {"우리"},
			},
			[4] = {
				name = "검은바위 나락",
				difficulty = {"normal"},
				keywords = {"바위나락"},
				excludekeywords = {"나락크"},
			},
			[5] = {
				name = "검은바위 첨탑 하층",
				difficulty = {"normal"},
				keywords = {"첨탑", "하층"},
				excludekeywords = {"우트"},
			},
			[6] = {
				name = "검은심연의 나락",
				difficulty = {"normal"},
				keywords = {"심연"},
			},
			[7] = {
				name = "놈리건",
				difficulty = {"normal"},
				keywords = {"놈리"},
			},
			[8] = {
				name = "마라우돈",
				difficulty = {"normal"},
				keywords = {"마라우돈", "우동"},
			},
			[9] = {
				name = "성난불길 협곡",
				difficulty = {"normal"},
				keywords = {"성난불길", "성불"},
			},
			[10] = {
				name = "스톰윈드 지하감옥",
				difficulty = {"normal"},
				keywords = {"감옥"},
			},
			[11] = {
				name = "스트라솔름",
				difficulty = {"normal"},
				keywords = {"남작"}, -- 솔름 키워드를 추가하지 마세요. 옛 솔름과 겹칩니다.
			},		
			[12] = {
				name = "울다만",
				difficulty = {"normal"},
				keywords = {"울다만"},
			},		
			[13] = {
				name = "줄파락",
				difficulty = {"normal"},
				keywords = {"즐파락"},
			},		
			[14] = {
				name = "통곡의 동굴",
				difficulty = {"normal"},
				keywords = {"통곡"},
			},
			[15] = {
				name = "혈투의 전장",
				difficulty = {"normal"},
				keywords = {"혈투", "혈장"},
			},
		},
	},
	[13] = {
		category = "군단 공격대",
		dungeon = {
			[1] = {
				name = "필드보스",
				difficulty = {"normal"},
				keywords = {"필드보스", "필보", "아나", "칼라", "드루곤", "바다떠돌이", "휴몽", "레반", "나자크", "니소그", "샤르", "영혼약탈자", "메마른 짐"},
			},
			[2] = {
				name = "에메랄드의 악몽",
				difficulty = {"normal", "heroic", "25lfr", "mythic"},
				keywords = {"에메", "에메랄드", "악몽", "자비"},
			},
			[3] = {
				name = "밤의 요새",
				difficulty = {"normal", "heroic", "25lfr", "mythic"},
				keywords = {"밤요", "밤의 요새", "굴단"},
			},
		},
	},
	[14] = {
		category = "군단 던전",
		dungeon = {
			[1] = {
				name = "감시관의 금고",
				difficulty = {"normal", "heroic", "mythic"},
				keywords = {"감시", "감시관", "금고"},
			},
			[2] = {
				name = "검은 떼까마귀 요새",
				difficulty = {"normal", "heroic", "mythic"},
				keywords = {"검떼까", "검요", "검은 떼"},
			},
			[3] = {
				name = "넬타리온의 둥지",
				difficulty = {"normal", "heroic", "mythic"},
				keywords = {"넬타", "넬타리온의 둥지", "넬둥"},
			},
			[4] = {
				name = "별의 궁정",
				difficulty = {"normal", "heroic", "mythic"},
				keywords = {"별궁", "별의 궁정","궁전"},
			},
			[5] = {
				name = "보랏빛 요새 침공",
				difficulty = {"normal", "heroic", "mythic"},
				keywords = {"보요"},
			},
			[6] = {
				name = "비전로",
				difficulty = {"normal", "heroic", "mythic"},
				keywords = {"비전로"},
			},
			[7] = {
				name = "아즈샤라의 눈",
				difficulty = {"normal", "heroic", "mythic"},
				keywords = {"아즈눈", "아즈"},
			},
			[8] = {
				name = "어둠심장 숲",
				difficulty = {"normal", "heroic", "mythic"},
				keywords = {"어숲", "어둠심장"},
			},
			[9] = {
				name = "영혼의 아귀",
				difficulty = {"normal", "heroic", "mythic"},
				keywords = {"영혼의 아귀", "아귀"},
			},
			[10] = {
				name = "용맹의 전당",
				difficulty = {"normal", "heroic", "mythic"},
				keywords = {"용전", "용맹의 전당", "용맹","전당"},
			},
			[11] = {
				name = "카라잔",
				difficulty = {"normal", "heroic", "mythic"},
				keywords = {"카라"},
			},
		},
	},
	[15] = {
		category = "기타",
		dungeon = {
			[1] = {
				name = "평점제 전장",
				difficulty = {"normal"},
				keywords = {"평전", "1승"},
			},
			[2] = {
				name = "투기장",
				difficulty = {"normal"},
				keywords = {"투기", "점먹", "8승", "10승", "2V2", "2VS2", "2대2", "3V3", "3VS3", "3대3","5V5", "5VS5", "5대5", "2:2", "3:3", "5:5"},
			},
			[3] = {
				name = "모의전",
				difficulty = {"normal"},
				keywords = {"모의"},
			},
		},
	},
}

-- 하드 난이도를 위한 별도 처리 부분입니다. 던전 모집 문구에 해당 문자열이 포함되어 있을 경우 하드 난이도로 분류 합니다.
FP_HEROIC_KEYWORDS = {"영웅", "하드", "%d+H", "H%d+", "HARD", "HEROIC", "ALLH", "올H"}

-- 던전명 뒤에 아래 문제가 붙어 있을 경우 하드 난이도로 인식합니다. (순전히 용영H 등 같은것으로 인해 추가..)
FP_HEROIC_POSTFIX_KEYWORDS = {"H"}

-- 모든 무시 키워드는 각단계 별로 별도로 제거 됩니다.
-- 즉, 다른 단계에서 사용한 키워드가 있다면 해당 단계에서 제거하는 것이 좋습니다.
-- 던전명 인식시 해당 문자열을 제거한후 던전명을 인식합니다. 오인식이 자주되는 키워드 위주로 추가하면 좋습니다.
-- 이를테면 도적의 키워드가 "도" 이고, 난이도 인식시 사용하는 키워드가 "도전" 이면, 직업 필터링에 "도전"을 추가하면 
-- 도전 모드는 정상적으로 인식되며 "도전" 을 도적으로 오인식하는 경우가 줄어듭니다.
-- 영어 사용시 대문자로만 적으세요. (자동으로 대문자 변환함)
FP_DUNGEON_IGNORE_KEYWORDS = {
	"OR", "AND", 
	"길드금고",--모구샨금고 오분류
	"황혼의고원", "황혼투기장",--황혼의 요새 오분류
	"할줄아",--줄아만 오분류
}

-- 던전 이름 뒤에 다음 문자열이 기록되어 있으면 무시합니다.
-- 운다손, 갈레온손 같은 경우를 제거하기 위함입니다.
FP_DUNGEON_IGNORE_POSTFIX_KEYWORDS = {
	"손",--운다 손
	"뜸",--운다 뜸
	"없",--운다 없나요?
	"ㅅ"--운다 ㅅㅅ
}

-- 난이도명 인식시 해당 문자열을 제거한후 난이도명을 인식합니다. 오인식이 자주되는 키워드 위주로 추가하면 좋습니다.
FP_DIFFICULTY_IGNORE_KEYWORDS = {
	--시간 관련 문자열들 제거
	"OR", "AND", "1탐", "2탐", "일시", "1시", "2시", "3시", "4시", "5시", "6시", "7시", "8시", "9시", "10시", "11시", "12시", "20시", "22시", "~1", "~10", ":33", "~33", "~20", "1~", "10~", "20~", "22:", "22~", ":55", "~55", "55분", "1:", "10:", "20:", ":0", ":1",
	--기타 오인식 문자열 제거
	 "10렙", "10레벨", "25렙", "25레벨", "1레벨", "1렙", "LV.25", "하드X", "10하드", "탄공이상",
}

-- 목록 툴팁에서 가독성에 영향을 주는 문자열을 사전 제거 합니다. 가능한 최소로 사용하세요.
FP_TOOLTIP_IGNORE_KEYWORDS = {
	-- 툴팁에는 이모티콘이 표시되지 않으므로 이모티콘 관련 문자들 제거
	"{해골}", "{별}", "{다이아몬드}", "{세모}", "{가위표}", "{동그라미}", "{달}", "{네모}", "{rt1}", "{rt2}", "{rt3}", "{rt4}", "{rt5}", "{rt6}", "{rt7}", "{rt8}"
}
