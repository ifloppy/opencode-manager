unit oc_i18n;

{$mode objfpc}{$H+}

interface

type
  TUiLanguage = (ulEnglish, ulChinese);

var
  CurrentUiLanguage: TUiLanguage = ulEnglish;

function UiText(const EnglishText, ChineseText: string): string;
function UiLanguageName(Language: TUiLanguage): string;

implementation

function UiText(const EnglishText, ChineseText: string): string;
begin
  case CurrentUiLanguage of
    ulChinese: Result := ChineseText;
  else
    Result := EnglishText;
  end;
end;

function UiLanguageName(Language: TUiLanguage): string;
begin
  case Language of
    ulChinese: Result := '中文';
  else
    Result := 'English';
  end;
end;

end.
