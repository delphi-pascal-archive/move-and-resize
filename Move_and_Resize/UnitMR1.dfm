object Form1: TForm1
  Left = 220
  Top = 127
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Move and Resize'
  ClientHeight = 225
  ClientWidth = 507
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 120
  TextHeight = 16
  object Label1: TLabel
    Left = 240
    Top = 168
    Width = 41
    Height = 16
    Caption = 'Label1'
  end
  object Edit1: TEdit
    Left = 208
    Top = 192
    Width = 169
    Height = 24
    TabOrder = 6
    Text = 'Edit1'
  end
  object RadioGroupControl: TRadioGroup
    Left = 8
    Top = 8
    Width = 129
    Height = 209
    Caption = ' Object control '
    ItemIndex = 0
    Items.Strings = (
      'None'
      'Label1'
      'Edit1'
      'Button1'
      'CheckBox1'
      'RadioGroup1'
      'Memo1')
    TabOrder = 0
    OnClick = RadioGroupControlClick
  end
  object CheckBoxMovable: TCheckBox
    Left = 144
    Top = 16
    Width = 81
    Height = 17
    Caption = 'Movable'
    Checked = True
    State = cbChecked
    TabOrder = 1
    OnClick = CheckBoxProprieteClick
  end
  object CheckBoxResizeable: TCheckBox
    Left = 144
    Top = 40
    Width = 97
    Height = 17
    Caption = 'Resizeable'
    Checked = True
    State = cbChecked
    TabOrder = 2
    OnClick = CheckBoxProprieteClick
  end
  object CheckBoxRedrawing: TCheckBox
    Left = 144
    Top = 88
    Width = 97
    Height = 17
    Caption = 'Redrawing'
    TabOrder = 4
    OnClick = CheckBoxProprieteClick
  end
  object MemoControl: TMemo
    Left = 264
    Top = 8
    Width = 233
    Height = 145
    Lines.Strings = (
      'Memo1')
    TabOrder = 5
  end
  object Button1: TButton
    Left = 392
    Top = 192
    Width = 105
    Height = 25
    Caption = 'Button1'
    TabOrder = 7
  end
  object CheckBox1: TCheckBox
    Left = 352
    Top = 168
    Width = 97
    Height = 17
    Caption = 'CheckBox1'
    TabOrder = 8
  end
  object CheckBoxBringToFront: TCheckBox
    Left = 144
    Top = 64
    Width = 113
    Height = 17
    Caption = 'BringToFront'
    TabOrder = 3
    OnClick = CheckBoxProprieteClick
  end
end
