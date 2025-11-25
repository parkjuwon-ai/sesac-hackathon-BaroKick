from fastapi import FastAPI, UploadFile, File
from pydantic import BaseModel
from typing import List, Literal
import uuid

app = FastAPI(title="SafeSign / BaroKick MVP API")


class RiskAction(BaseModel):
    type: str   # 예: "문의", "신고", "유지"
    label: str  # 버튼에 보여줄 문구


class TimelineDate(BaseModel):
    label: str  # 예: "계약만료일", "자동갱신예정", "청약철회마감"
    value: str  # ISO 날짜 문자열 "2025-12-31"


class AnalyzeResponse(BaseModel):
    document_id: str
    summary: str
    risk_flags: List[str]
    risk_level: Literal["low", "medium", "high"]
    actions: List[RiskAction]
    dates: List[TimelineDate]


@app.get("/health")
def health_check():
    return {"status": "ok", "service": "safesign-mvp"}


@app.post("/analyze_contract", response_model=AnalyzeResponse)
async def analyze_contract(file: UploadFile = File(...)):
    """
    ⚠️ MVP 버전:
    아직 OCR/OLLAMA 연동 전이므로,
    고정된 더미 응답을 반환합니다.
    """
    fake_id = str(uuid.uuid4())

    return AnalyzeResponse(
        document_id=fake_id,
        summary=(
            "이 계약은 2년 약정과 자동 갱신 조항을 포함하고 있으며, "
            "중도 해지 시 잔여 이용료의 30%에 해당하는 위약금이 청구됩니다."
        ),
        risk_flags=["자동갱신", "장기약정", "위약금_높음"],
        risk_level="high",
        actions=[
            RiskAction(
                type="문의",
                label="사업자에게 해지 조건과 위약금 계산 방식을 먼저 문의하기"
            ),
            RiskAction(
                type="신고",
                label="소비자원(1372)에 분쟁조정 신청 여부 상담하기"
            ),
            RiskAction(
                type="유지",
                label="필요 시 가족/보호자와 상의 후 신중히 서명 진행하기"
            ),
        ],
        dates=[
            TimelineDate(label="계약시작일(예상)", value="2025-01-01"),
            TimelineDate(label="계약만료일", value="2027-12-31"),
            TimelineDate(label="자동갱신예정", value="2026-01-01"),
            TimelineDate(label="청약철회마감(예시)", value="2025-01-08"),
        ],
    )
