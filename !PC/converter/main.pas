unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, XPMan, Grids, ValEdit;

type
  TfrmMain = class(TForm)
    ed_filename: TEdit;
    Label1: TLabel;
    btn_Do: TButton;
    m_Out: TMemo;
    XPManifest1: TXPManifest;
    gb_Settings: TGroupBox;
    vle_Info: TValueListEditor;
    Label2: TLabel;
    ed_increase: TEdit;
    procedure btn_DoClick(Sender: TObject);
    procedure ed_increaseChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

procedure TfrmMain.btn_DoClick(Sender: TObject);
// ��������� ���� � ������������� ������� � �������
const
  head: string = 'Data ';
  separator: string = ',';
  prefix: string = '&H';
  s_max_len: byte = 9;
  f_max_len: cardinal = 30720;   // 30 �����
var
  f: TFileStream;
  b: byte;
  i: cardinal;
  s: string;
  s_len: byte;
  c: single;
  pwm_begin, pwm_end, over_amount: cardinal;
begin
  try
    f := TFileStream.Create(ed_filename.Text, fmOpenRead);
  except
    ShowMessage('�������� ����!');
    exit
  end;

  try
    c := strtofloat(ed_increase.Text);
    if c < 0 then Assert(false, '123');
  except
    ShowMessage('�������� �����������!');
    exit
  end;


  s := head;
  s_len := 0;
  pwm_begin := 0;
  pwm_end := 0;
  over_amount := 0;
  m_Out.Clear;
  while f.Read(b,1) <> 0 do
  begin
    // �������� �� ���������
    inc(pwm_begin, b);
    // ����������� ����
      if round(b*c) > 255 then
      begin
        b := 255;
        inc(over_amount);
      end else
        b := round(b*c);
    // �������� ����� ���������
    inc(pwm_end, b);
    s := s + prefix + inttohex(b,2) + separator;
    inc(s_len);
    if s_len = s_max_len then
    begin
      delete(s, length(s)-length(separator)+1, length(separator));
      m_Out.Lines.Append(s);
      s := head;
      s_len := 0; 
    end;
    if f.Position > f_max_len then break;
  end;
  if s <> head then
  begin
    delete(s, length(s)-length(separator)+1, length(separator));
    m_Out.Lines.Append(s);
  end;

  // ������ ���������� ��������������
  c := f.Position+1;
  with vle_Info do
  begin
    Values['������']          := inttostr(f.Position + 1);
    Values['���������������'] := formatfloat('0.00', over_amount/c*100)+'%';
    Values['~��� ��']         := formatfloat('0.00', pwm_begin/c);
    Values['~��� �����']      := formatfloat('0.00', pwm_end/c);
  end;

  f.Free;
end;

procedure TfrmMain.ed_increaseChange(Sender: TObject);
// ������ ��������� ������ - ������������ ������� �����
var
  p: byte;
  s: string;
begin
  p := pos('.', ed_increase.Text);
  with ed_increase do
    if p <> 0 then
    begin
      s := Text;
      s[p] := ',';
      Text := s;
      SelStart := length(s);
      SelLength := 0;
    end
end;

end.
