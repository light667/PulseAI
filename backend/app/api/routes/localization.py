from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Dict
from langchain_mistralai import ChatMistralAI
from langchain_core.prompts import PromptTemplate
from app.core.config import settings
import json

router = APIRouter()

class TranslationRequest(BaseModel):
    target_language: str
    texts: Dict[str, str]

class TranslationResponse(BaseModel):
    translations: Dict[str, str]

TRANSLATION_PROMPT = """
You are an expert translator specializing in medical terminology and modern application user interfaces.
Translate the following JSON key-value pairs from English to {target_language}.
Ensure the tone is professional, reassuring, and contextually accurate for a medical app used in Africa.
If the language is Ewe (Ɛʋɛgbe), Kotokoli (Tem), or Fon, use culturally appropriate vocabulary.
Return ONLY a valid JSON object matching the keys precisely, with the translated strings as values.
Do not wrap in Markdown blocks (like ```json), just output the raw JSON.

JSON to translate:
{json_texts}
"""

@router.post("/translate", response_model=TranslationResponse)
async def translate_ui(request: TranslationRequest):
    try:
        llm = ChatMistralAI(model="mistral-large-latest", mistral_api_key=settings.MISTRAL_API_KEY)
        
        prompt = PromptTemplate(
            input_variables=["target_language", "json_texts"],
            template=TRANSLATION_PROMPT
        )
        
        chain = prompt | llm
        
        input_json_str = json.dumps(request.texts, ensure_ascii=False)
        
        response = chain.invoke({
            "target_language": request.target_language,
            "json_texts": input_json_str
        })
        
        # Clean up output if Mistral decides to add markdown brackets anyway
        output_str = response.content.strip()
        if output_str.startswith("```json"):
            output_str = output_str[7:]
        if output_str.startswith("```"):
            output_str = output_str[3:]
        if output_str.endswith("```"):
            output_str = output_str[:-3]
            
        translated_dict = json.loads(output_str.strip())
        
        return TranslationResponse(translations=translated_dict)
        
    except json.JSONDecodeError:
        raise HTTPException(status_code=500, detail="Mistral returned an invalid JSON structure.")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
