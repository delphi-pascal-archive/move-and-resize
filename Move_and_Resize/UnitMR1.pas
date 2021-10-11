unit UnitMR1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, MoveAndResize;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    Edit1: TEdit;
    RadioGroupControl: TRadioGroup;
    CheckBoxMovable: TCheckBox;
    CheckBoxResizeable: TCheckBox;
    CheckBoxRedrawing: TCheckBox;
    MemoControl: TMemo;
    Button1: TButton;
    CheckBox1: TCheckBox;
    CheckBoxBringToFront: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure RadioGroupControlClick(Sender: TObject);
    procedure CheckBoxProprieteClick(Sender: TObject);
    procedure MoveAndResizeMoveOrResize(Sender: TObject);
  end;

var
  Form1: TForm1;

implementation
{$R *.dfm}
// Création dynamique de l'objet pour éviter le référencement dans l'IDE !
var
   MoveAndResize1 : TMoveAndResize;
procedure TForm1.FormCreate(Sender: TObject);
begin
     MoveAndResize1 := MoveAndResize.TMoveAndResize.Create( Self );
end;

procedure TForm1.RadioGroupControlClick(Sender: TObject);
begin
     CheckBoxProprieteClick( NIL );
     case RadioGroupControl.ItemIndex of
          0 : MoveAndResize1.Control := NIL;
          1 : MoveAndResize1.Control := Label1;
          2 : MoveAndResize1.Control := Edit1;
          3 : MoveAndResize1.Control := Button1;
          4 : MoveAndResize1.Control := CheckBox1;
          5 : MoveAndResize1.Control := RadioGroupControl;
          6 : MoveAndResize1.Control := MemoControl;
     end;
end;

procedure TForm1.CheckBoxProprieteClick(Sender: TObject);
begin
     MoveAndResize1.Movable := CheckBoxMovable.Checked;
     MoveAndResize1.Resizeable := CheckBoxResizeable.Checked;
     MoveAndResize1.BringToFront := CheckBoxBringToFront.Checked;
     MoveAndResize1.Redrawing := CheckBoxRedrawing.Checked;
end;

procedure TForm1.MoveAndResizeMoveOrResize(Sender: TObject);
var
   Control : TControl;
begin
     Control := TMoveAndResize( Sender ).Control;
     MemoControl.Lines.BeginUpdate;
     MemoControl.Lines.Clear;
     MemoControl.Lines.Add( 'Control = ' + Control.Name );
     MemoControl.Lines.Add( 'Left = ' + IntToStr( Control.Left ) );
     MemoControl.Lines.Add( 'Top = ' + IntToStr( Control.Top ) );
     MemoControl.Lines.Add( 'Height = ' + IntToStr( Control.Height ) );
     MemoControl.Lines.Add( 'Width = ' + IntToStr( Control.Width ) );
     MemoControl.Lines.EndUpdate;
end;

end.
