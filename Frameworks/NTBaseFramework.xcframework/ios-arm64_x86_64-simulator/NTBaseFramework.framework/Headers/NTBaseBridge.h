//
//  NTBaseBridge.h
//  NTBaseFramework
//
//  Unreal(C++) ↔ NTBaseFramework(Swift) 공통 브릿지.
//
//  언리얼 게임 코드는 C++라 Swift/ObjC의 block · UIViewController · NSString을
//  직접 다룰 수 없다. 이 헤더는 모든 기능을 C++에서 호출 가능한 평면 C 함수로
//  노출하고, 결과를 "호출당 컨텍스트 콜백"(함수 포인터 + userdata)으로 돌려준다.
//
//  공통 콜백 규약:
//   - 모든 콜백은 메인 스레드에서 호출된다.
//   - const char* 인자는 콜백이 반환되는 즉시 무효화된다. 보관이 필요하면
//     수신측이 직접 복사할 것. (free 금지)
//   - userdata는 호출 시 넘긴 포인터를 그대로 되돌려준다.
//     (예: 언리얼 델리게이트/객체 포인터를 컨텍스트로 전달)
//   - presentingViewController가 필요한 기능(Consent/AgeRange)은 브릿지가
//     내부에서 keyWindow의 최상위 뷰 컨트롤러를 자동으로 확보한다.
//

#ifndef NTBaseBridge_h
#define NTBaseBridge_h

#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

#pragma mark - Web Authentication

/// 웹 인증 결과 콜백. (메인 스레드에서 호출)
/// @param payload  성공 시 콜백 URL의 **percent-디코딩된** query(없으면 fragment) 문자열,
///                 실패 시 사람이 읽을 수 있는 취소/오류 메시지.
/// @param success  true=콜백 수신, false=사용자 취소/세션 오류.
/// @param userdata 호출 시 넘긴 포인터 그대로.
typedef void (*NTBaseBridgeAuthResultCallback)(const char* payload, bool success, void* userdata);

/// 외부 웹 인증(OAuth 등) 플로우를 시작한다. 동시에 하나만 진행 가능.
/// @param authURL        인증 시작 URL. 예: "https://auth.example.com/oauth/authorize?client_id=abc&redirect_uri=myapp://cb"
/// @param callbackScheme 콜백 URL 스킴. 예: "myapp"
///
/// 예시 콜백 데이터:
///   - 성공: payload = "code=AUTH_CODE&state=xyz",                    success = true
///   - 취소: payload = "User Cancel",                                 success = false
///   - 오류: payload = "Error: Authentication already in progress",   success = false
void NTBaseBridge_StartWebAuthentication(const char* authURL,
                                         const char* callbackScheme,
                                         NTBaseBridgeAuthResultCallback callback,
                                         void* userdata);

#pragma mark - Consent (UMP)

/// 동의 요청 결과 콜백. (메인 스레드)
/// @param status       "UNKNOWN" / "REQUIRED" / "NOT_REQUIRED" / "OBTAINED"
/// @param errorMessage 오류 시 메시지, 없으면 NULL.
/// @param userdata     호출 시 넘긴 포인터 그대로.
typedef void (*NTBaseBridgeConsentResultCallback)(const char* status, const char* errorMessage, void* userdata);

/// 동의 초기화 결과 콜백. (메인 스레드)
/// @param errorMessage 오류 시 메시지, 없으면 NULL.
typedef void (*NTBaseBridgeConsentResetCallback)(const char* errorMessage, void* userdata);

/// (선택) 테스트/디버그 설정. 앱 시작 시 1회 호출.
/// @param debugGeography       0=DISABLED, 1=EEA, 2=OTHER(notEEA), 3=REGULATED_US_STATE (NTDebugGeography rawValue와 일치)
/// @param testDeviceIds        테스트 기기 ID(광고 로그의 "test device") C 문자열 배열, NULL 가능.
/// @param testDeviceIdCount    testDeviceIds 개수(0 가능).
/// @param tagForUnderAgeOfConsent 미성년 태그 여부.
///
/// 예시 입력:
///   debugGeography = 1 (EEA)
///   testDeviceIds  = {"33BE2250B43518CCDA7DE05...E1"}, testDeviceIdCount = 1
///   tagForUnderAgeOfConsent = false
void NTBaseBridge_ConfigureConsent(int debugGeography,
                                   const char* const* testDeviceIds,
                                   int testDeviceIdCount,
                                   bool tagForUnderAgeOfConsent);

/// 필요 시 UMP 동의 폼을 표시한다.
///
/// 예시 콜백 데이터:
///   - 동의 완료: status = "OBTAINED",     errorMessage = NULL
///   - 불필요:    status = "NOT_REQUIRED", errorMessage = NULL
///   - 오류:      status = "UNKNOWN",      errorMessage = "The operation couldn't be completed..."
void NTBaseBridge_RequestConsentIfNeeded(NTBaseBridgeConsentResultCallback callback, void* userdata);

/// 광고 요청 가능 여부(동기). 예시 반환: true
bool NTBaseBridge_CanRequestAds(void);

/// Debug/QA 전용: 동의 상태 초기화.
/// 예시 콜백 데이터: errorMessage = NULL
void NTBaseBridge_ResetConsentForDebug(NTBaseBridgeConsentResetCallback callback, void* userdata);

#pragma mark - Declared Age Range

/// 사용 가능 여부 콜백. (메인 스레드)
/// @param eligible     기능 사용 가능 여부. iOS 26.2 미만은 항상 false.
/// @param errorMessage 오류 시 메시지, 없으면 NULL.
typedef void (*NTBaseBridgeEligibleCallback)(bool eligible, const char* errorMessage, void* userdata);

/// 시스템 나이 범위 선언 기능 사용 가능 여부.
/// 예시 콜백 데이터:
///   - 가능:   eligible = true,  errorMessage = NULL
///   - 미지원: eligible = false, errorMessage = NULL   (iOS 26.2 미만)
void NTBaseBridge_IsEligibleForDeclaredAgeRange(NTBaseBridgeEligibleCallback callback, void* userdata);

/// 나이 범위 선언 결과 콜백. (메인 스레드)
/// @param code          "SHARING" / "DECLINED" / "NOT_SUPPORTED" / "ERROR" / "UNKNOWN"
/// @param hasLowerBound lowerBound 유효 여부. false면 lowerBound 값은 무의미(0).
/// @param lowerBound    나이 하한(hasLowerBound=true일 때).
/// @param hasUpperBound upperBound 유효 여부. false면 upperBound 값은 무의미(0).
/// @param upperBound    나이 상한(hasUpperBound=true일 때).
/// @param declaration   나이 범위 선언 문자열, 없으면 NULL.
/// @param errorMessage  오류 시 메시지, 없으면 NULL.
typedef void (*NTBaseBridgeAgeRangeResultCallback)(const char* code,
                                                   bool hasLowerBound, int lowerBound,
                                                   bool hasUpperBound, int upperBound,
                                                   const char* declaration,
                                                   const char* errorMessage,
                                                   void* userdata);

/// 나이 범위 선언을 요청한다. ageGate2/ageGate3는 사용 안 하면 0.
/// @param ageGate1/2/3 나이 게이트 임계값. 예: 13 / 16 / 18 (2·3 미사용 시 0)
///
/// 예시 콜백 데이터:
///   - 공유:   code="SHARING", hasLowerBound=true, lowerBound=13, hasUpperBound=false, upperBound=0, declaration=NULL, errorMessage=NULL
///   - 거부:   code="DECLINED", false,0, false,0, NULL, NULL
///   - 미지원: code="NOT_SUPPORTED", false,0, false,0, NULL, NULL   (iOS 26.2 미만)
///   - 오류:   code="ERROR", false,0, false,0, NULL, "<메시지>"
void NTBaseBridge_RequestDeclaredAgeRange(int ageGate1, int ageGate2, int ageGate3,
                                          NTBaseBridgeAgeRangeResultCallback callback, void* userdata);

#pragma mark - Permission (PermissionKit, iOS 26.2+)

// PermissionKit은 "요청(ask) → 시스템 UI → 이후 응답이 도착"하는 모델이라
// 일회성이 아니다. 응답은 리스너로 구독하고, 요청은 전송 개시 여부로 분리한다.
// 이 모듈은 결과의 의미를 해석하지 않고 그대로 전달한다(transport, docs/DESIGN_DECISIONS.md D5).

/// 승인/거부 응답 콜백. 응답이 도착할 때마다 호출된다.
/// @param jsonResponse 모든 응답 필드를 담은 JSON 문자열. 예:
///        {"code":"APPROVED","topic":"COMMUNICATION","handle":"dragonslayer42",
///         "action":"chat","displayName":"A","choiceTitle":"Approve","choiceId":"approve","questionId":"<UUID>"}
///        code: "APPROVED"/"DECLINED"/"UNKNOWN", topic: "SIGNIFICANT_APP_UPDATE"/"COMMUNICATION".
///        값이 없는 필드는 생략된다.
typedef void (*NTBaseBridgePermissionResponseCallback)(const char* jsonResponse, void* userdata);

/// 응답 구독 시작. **어떤 ask보다 먼저, 앱 시작 시** 호출하고 유지할 것.
/// (미지원 OS에서는 응답이 오지 않는다)
void NTBaseBridge_StartPermissionResponseListener(NTBaseBridgePermissionResponseCallback callback, void* userdata);

/// 응답 구독 중지.
void NTBaseBridge_StopPermissionResponseListener(void);

/// 요청 전송 결과 콜백. (메인 스레드)
/// @param started      전송(시스템 UI 표시)이 개시되었는지. 실제 승인/거부는 리스너로 도착.
/// @param errorMessage 오류 시 메시지(미지원 OS 포함), 없으면 NULL.
typedef void (*NTBaseBridgeAskResultCallback)(bool started, const char* errorMessage, void* userdata);

/// 중대 앱 변경에 대한 보호자 동의를 요청한다.
/// @param description 보호자에게 보여줄 변경 설명. 예: "This update adds video calling and location sharing."
///
/// 예시 콜백 데이터(전송 결과):
///   - 전송됨:  started = true,  errorMessage = NULL
///   - 미지원:  started = false, errorMessage = "PermissionKit requires iOS 26.2"
/// (실제 승인/거부는 StartPermissionResponseListener의 JSON 응답으로 도착)
void NTBaseBridge_AskSignificantAppUpdatePermission(const char* description,
                                                    NTBaseBridgeAskResultCallback callback, void* userdata);

/// 특정 상대와의 커뮤니케이션 권한을 보호자에게 요청한다. (소셜 행위 직전, 대상별로 호출)
/// @param handle      대상 식별자. 예: "dragonslayer42"
/// @param handleKind  0=phoneNumber, 1=emailAddress, 2=custom
/// @param action      0=message,1=chat,2=call,3=videoCall,4=audioCall,5=friend,6=follow,7=beFollowed,8=communicate,9=connect
/// @param displayName 보호자 프롬프트에 표시할 대상 이름(없으면 NULL). 예: "A"
///
/// 예시 입력: handle="dragonslayer42", handleKind=2(custom), action=1(chat), displayName="A"
/// 예시 콜백 데이터: started = true, errorMessage = NULL
/// (실제 승인/거부는 리스너 JSON 응답으로 도착. 재요청 방지를 위해 아래 IsCommunicationHandleKnown를 먼저 확인)
void NTBaseBridge_AskCommunicationPermission(const char* handle, int handleKind,
                                             int action, const char* displayName,
                                             NTBaseBridgeAskResultCallback callback, void* userdata);

/// 이미 보호자가 승인한(known) 상대인지 조회 결과 콜백. (메인 스레드)
/// @param known true=이미 승인됨(재요청 불필요), false=미승인.
typedef void (*NTBaseBridgeKnownHandleCallback)(bool known, void* userdata);

/// 이미 승인된 상대인지 조회한다. ask 전에 확인해 재요청을 피한다.
/// @param handle     대상 식별자. 예: "dragonslayer42"
/// @param handleKind 0=phoneNumber, 1=emailAddress, 2=custom
///
/// 예시 입력: handle="dragonslayer42", handleKind=2
/// 예시 콜백 데이터: known = true  (또는 false → 이때만 AskCommunicationPermission 호출)
void NTBaseBridge_IsCommunicationHandleKnown(const char* handle, int handleKind,
                                             NTBaseBridgeKnownHandleCallback callback, void* userdata);

#ifdef __cplusplus
}
#endif

#endif /* NTBaseBridge_h */
