{*******************************************************************************
 * TMoveAndResize
 * Adapté par HURPY Frédéric - 04/03/08
 * A partir du code de MARTINEAU Emeric de WinEssential project (php4php.free.fr)
 ******************************************************************************* }
unit MoveAndResize;

interface

uses
  Windows, Classes, Graphics, Controls, StdCtrls, ExtCtrls;

type
  TMoveAndResize = class(TComponent)
  private
    // Control controlé
    FControl : TControl;
    FMovable : Boolean;
    FResizeable : Boolean;
    FBringToFront : Boolean;
    FRedrawing : Boolean;
    FMinHeight : Integer;
    FMinWidth : Integer;
    // Curseurs de redimensionnement
    FCursorColor : TColor;
    FCursorHeight, FCursorHeight2 : Integer;
    FCursorWidth, FCursorWidth2 : Integer;
    FCursorBevelInner : TBevelCut;
    FCursorBevelOuter : TBevelCut;
    // Panels de redimensionnement
    FPanelBasGauche : TPanel;
    FPanelGauche : TPanel;
    FPanelHautGauche : TPanel;
    FPanelHaut : TPanel;
    FPanelHautDroit : TPanel;
    FPanelDroit : TPanel;
    FPanelBasDroit : TPanel;
    FPanelBas : TPanel;
    FPanels : array[ 1..8 ] of TPanel; // Panels ci-dessus
    // Evènements
    FOnMove : TNotifyEvent;
    FOnResize : TNotifyEvent;
    // Variables de stockage
    FOldCursor : TCursor;
    FOldOnMouseDown : TMouseEvent;
    FOldOnMouseMove : TMouseMoveEvent;
    PosX, PosY : Integer; // Mémorisation de la position souris
  private
    // CONTEXTE
    procedure ContextSave;
    procedure ContextRestaure;
    // REDIMENSIONNEMENT
    procedure ResizeInit( Panel : TPanel; var P : TPoint;
                          var INewLeft, INewTop : Longint;
                          var IControlLeft, IControlTop, IControlWidth, IControlHeight : Longint );
    procedure ResizeDone( IControlLeft, IControlTop, IControlWidth, IControlHeight : Longint );
    // DEPLACEMENTS
    procedure BasGaucheMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure GaucheMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure HautGaucheMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure HautMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure HautDroitMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DroitMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure BasDroitMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure BasMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
  protected
    // CONTROL CONTROLE
    procedure SetControl(control:TControl);
    procedure SetMovable( Value : Boolean );
    procedure SetResizable( Value : Boolean );
    // CURSEURS DE REDIMENSIONNEMENT
    procedure CreateCursors;
    procedure ShowCursors;
    procedure MyMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure MyMouseDown(Sender : TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure MyResizeMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    // CURSEURS : PROPRIETES
    procedure SetColor(color:TColor);
    procedure SetCursorHeight(value:integer);
    procedure SetCursorWidth(value:integer);
    procedure SetCursorBevelInner(bevel:TBevelCut);
    procedure SetCursorBevelOuter(bevel:TBevelCut);
  public
    constructor Create( Owner : TComponent ); override;
    destructor Destroy; override;
  published
    // CONTROL CONTROLE
    property Control : TControl read FControl write SetControl;
    property Movable : Boolean read FMovable write SetMovable;
    property Resizeable : Boolean read FResizeable write SetResizable;
    property BringToFront : Boolean read FBringToFront write FBringToFront;
    property Redrawing : Boolean read FRedrawing write FRedrawing;
    property MinHeight : Integer read FMinHeight write FMinHeight;
    property MinWidth : Integer read FMinWidth write FMinWidth;
    // CURSEURS DE REDIMENSIONNEMENT
    property CursorColor : TColor read FCursorColor write SetColor;
    property CursorHeight : Integer read FCursorHeight write SetCursorHeight;
    property CursorWidth : Integer read FCursorWidth write SetCursorWidth;
    property CursorBevelInner : TBevelCut read FCursorBevelInner write SetCursorBevelInner;
    property CursorBevelOuter : TBevelCut read FCursorBevelOuter write SetCursorBevelOuter;
    // EVENEMENTS
    property OnMove : TNotifyEvent read FOnMove write FOnMove;
    property OnResize : TNotifyEvent read FOnResize write FOnResize;
  end;

procedure Register;

implementation
procedure Register;
begin
     RegisterComponents( 'AddOn', [ TMoveAndResize ] );
end;
{ ============================================================================
  GENERAL
  ============================================================================ }
constructor TMoveAndResize.Create( Owner : TComponent );
begin
     inherited ;
     // Control controlé
     FControl := NIL;
     ContextRestaure;
     Movable := False;
     Resizeable := False;
     FBringToFront := False;
     FRedrawing := False;
     MinHeight := 5;
     MinWidth := 5;
     // Curseurs de redimensionnement
     CreateCursors;
     CursorColor := clBlack;
     CursorHeight := 5;
     CursorWidth := 5;
     CursorBevelInner := bvNone;
     CursorBevelOuter := bvNone;
end;

destructor TMoveAndResize.Destroy;
var
   I : Longint;
begin
     ContextRestaure;
     FControl := NIL;
     for I := 1 to 8 do FPanels[ I ].Parent := NIL;
     inherited;
end;

{ ============================================================================
  CONTEXTE
  ============================================================================ }
procedure TMoveAndResize.ContextSave;
var
   MouseDown : TMouseEvent;
   MouseMove : TMouseMoveEvent;
begin
     if Assigned( FControl ) then
        begin
        if FOldCursor = -32768 then
           begin // Stockage si non stocké
           FOldCursor := FControl.Cursor;
           FControl.Cursor := crSizeAll;
           end;
        MouseDown := MyMouseDown;
        if @FOldOnMouseDown = @MouseDown then
           begin // Stockage si non stocké
           FOldOnMouseDown := TButton( FControl ).OnMouseDown;
           TButton( FControl ).OnMouseDown := MyMouseDown;
           end;
        MouseMove := MyMouseMove;
        if @FOldOnMouseMove = @MouseMove then
           begin // Stockage si non stocké
           FOldOnMouseMove := TButton( FControl ).OnMouseMove;
           TButton( FControl ).OnMouseMove := MyMouseMove;
           end;
        end;
end;

procedure TMoveAndResize.ContextRestaure;
var
   MouseDown : TMouseEvent;
   MouseMove : TMouseMoveEvent;
begin
     if Assigned( FControl ) then
        begin
        if FOldCursor <> -32768
           then FControl.Cursor := FOldCursor;
        MouseDown := MyMouseDown;
        if @FOldOnMouseDown <> @MouseDown
           then TButton( FControl ).OnMouseDown := FOldOnMouseDown
           else TButton( FControl ).OnMouseDown := NIL;
        MouseMove := MyMouseMove;
        if @FOldOnMouseMove <> @MouseMove
           then TButton( FControl ).OnMouseMove := FOldOnMouseMove
           else TButton( FControl ).OnMouseMove := NIL;
        end;
     // Valeurs non stockées
     FOldCursor := -32768;
     FOldOnMouseDown := MyMouseDown;
     FOldOnMouseMove := MyMouseMove;
end;

{ ============================================================================
  CONTROL CONTROLE
  ============================================================================ }
procedure TMoveAndResize.SetControl( Control : TControl );
var
   I : Longint;
begin
     if FControl <> Control
        then ContextRestaure;
     FControl := Control;
     if Assigned( FControl ) then
        begin // Nouveau control
        if FBringToFront
           then FControl.BringToFront; // Evite le passage sous les autres objets
        for I := 1 to 8 do begin
            FPanels[ I ].Visible := False;
            FPanels[ I ].Parent := FControl.Parent;
            if FBringToFront
               then FPanels[ I ].BringToFront; // Dessus le control
        end;
        Self.Movable := Self.Movable;
        Self.Resizeable := Self.Resizeable;
        end
     else for I := 1 to 8 do FPanels[ I ].Parent := NIL; // Plus de control
end;

procedure TMoveAndResize.SetMovable( Value : Boolean );
begin
     FMovable := Value;
     if not( csDesigning in ComponentState ) then
        begin
        if FMovable
           then ContextSave
           else ContextRestaure;
        if FMovable and Assigned( FOnMove ) and Assigned( Control )
           then FOnMove( Self );
        end;
end;

procedure TMoveAndResize.SetResizable( Value : Boolean );
var
   I : Longint;
begin
     FResizeable := Value;
     if not( csDesigning in ComponentState ) then
        begin
        if Assigned( FPanels[ 1 ] )
           then for I := 1 to 8 do FPanels[ I ].Visible := False;
        if FResizeable and Assigned( FControl ) then
           begin // Affichage curseurs
           ShowCursors;
           for I := 1 to 8 do FPanels[ I ].Visible := True;
           end;
        if FResizeable and Assigned( FOnResize ) and Assigned( Control ) 
           then FOnResize( Self );
        end;
end;

{ ============================================================================
  CURSEURS DE REDIMENSIONNEMENT
  ============================================================================ }
procedure TMoveAndResize.CreateCursors;
   procedure PanelCreate( IIndice : Longint; var Panel : TPanel; Cursor : TCursor; MouveMove : TMouseMoveEvent );
   begin
        Panel := TPanel.Create( Self );
        Panel.Visible := False;
        Panel.Caption := '';
        Panel.Cursor := Cursor;
        Panel.OnMouseMove := MouveMove;
        Panel.OnMouseDown := MyResizeMouseDown;
        FPanels[ IIndice ] := Panel;
   end;
begin
     // Création des panels
     PanelCreate( 1, FPanelBasGauche, crSizeNESW, BasGaucheMouseMove );
     PanelCreate( 2, FPanelGauche, crSizeWE, GaucheMouseMove );
     PanelCreate( 3, FPanelHautGauche, crSizeNWSE, HautGaucheMouseMove );
     PanelCreate( 4, FPanelHaut, crSizeNS, HautMouseMove );
     PanelCreate( 5, FPanelHautDroit, crSizeNESW, HautDroitMouseMove );
     PanelCreate( 6, FPanelDroit, crSizeWE, DroitMouseMove );
     PanelCreate( 7, FPanelBasDroit, crSizeNWSE, BasdroitMouseMove );
     PanelCreate( 8, FPanelBas, crSizeNS, BasMouseMove );
     // Affichage initial des panels
     SetColor( FCursorColor );
     SetCursorHeight( FCursorHeight );
     SetCursorWidth( FCursorWidth );
     SetCursorBevelInner( FCursorBevelInner );
     SetCursorBevelOuter( FCursorBevelInner );
end;

procedure TMoveAndResize.ShowCursors;
   procedure PanelMAJ( Panel : TPanel; ILeft, ITop : Longint );
   begin
        Panel.SetBounds( ILeft, ITop, Panel.Width, Panel.Height );
   end;
begin
     PanelMAJ( FPanelBasGauche,
               FControl.Left - FCursorWidth2, FControl.Top + FControl.Height - FCursorHeight2 );
     PanelMAJ( FPanelGauche,
               FPanelBasGauche.Left, FControl.Top + ( FControl.Height div 2 ) - FCursorHeight2 );
     PanelMAJ( FPanelHautGauche,
               FPanelBasGauche.Left, FControl.Top - FCursorHeight2 );
     PanelMAJ( FPanelHaut,
               FControl.Left + ( FControl.Width div 2 ) - FCursorWidth2, FPanelHautGauche.Top );
     PanelMAJ( FPanelHautDroit,
               FControl.Left + FControl.Width - FCursorWidth2, FPanelHautGauche.Top );
     PanelMAJ( FPanelDroit,
               FPanelHautDroit.Left, FPanelGauche.Top );
     PanelMAJ( FPanelBasDroit,
               FPanelHautDroit.Left, FPanelBasGauche.Top );
     PanelMAJ( FPanelBas,
               FPanelHaut.Left, FPanelBasGauche.Top );
end;

procedure TMoveAndResize.MyMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
   P : TPoint;
   INewLeft, INewTop : Longint;
begin
    if ssLeft in Shift then
       begin
       GetCursorPos( P );
       // Gauche
       INewLeft := FControl.Left + ( P.X - FControl.ClientOrigin.X ) - PosX;
       if INewLeft < 0
          then INewLeft := 0;
       if INewLeft + FControl.Width > FControl.Parent.ClientWidth
          then INewLeft := FControl.Parent.ClientWidth - FControl.Width;
       // Haut
       INewTop := FControl.Top + ( P.Y - FControl.ClientOrigin.Y ) - PosY;
       if INewTop < 0
          then INewTop := 0;
       if INewTop + FControl.Height > FControl.Parent.ClientHeight
          then INewTop := FControl.Parent.ClientHeight - FControl.Height;
       // Positionnement et affichage
       if ( INewLeft <> FControl.Left ) or ( INewTop <> FControl.Top ) then
          begin
          FControl.SetBounds( INewLeft, INewTop, FControl.Width, FControl.Height );
          if FRedrawing
             then FControl.Update; // Invalidate déjà appelé par SetBounds
          ShowCursors;
          if Assigned( FOnMove )
             then FOnMove( Self );
          end;
       end;
end;

procedure TMoveAndResize.MyMouseDown(Sender : TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
   P : TPoint;
begin
     GetCursorPos( P );
     PosY := P.Y - TControl( Sender ).ClientOrigin.Y;
     PosX := P.X - TControl( Sender ).ClientOrigin.X;
end;

procedure TMoveAndResize.MyResizeMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
   P : TPoint;
begin
     GetCursorPos( P );
     PosY := P.Y - TControl( Sender ).ClientOrigin.Y;
     PosX := P.X - TControl( Sender ).ClientOrigin.X;
end;

{ ============================================================================
  CURSEURS : PROPRIETES
  ============================================================================ }
procedure TMoveAndResize.SetCursorHeight( Value : Integer );
var
   I : Longint;
begin
     FCursorHeight := Value;
     FCursorHeight2 := Value div 2;
     for I := 1 to 8 do FPanels[ I ].Height := Value;
end;

procedure TMoveAndResize.SetCursorWidth( Value : Integer );
var
   I : Longint;
begin
     FCursorWidth := Value;
     FCursorWidth2 := Value div 2;
     for I := 1 to 8 do FPanels[ I ].Width := Value;
end;

procedure TMoveAndResize.SetColor( Color : TColor );
var
   I : Longint;
begin
     FCursorColor := Color;
     for I := 1 to 8 do FPanels[ I ].Color := Color;
end;

procedure TMoveAndResize.SetCursorBevelInner( Bevel : TBevelCut );
var
   I : Longint;
begin
     FCursorBevelInner := Bevel;
     for I := 1 to 8 do FPanels[ I ].BevelInner := Bevel;
end;

procedure TMoveAndResize.SetCursorBevelOuter( Bevel : TBevelCut );
var
   I : Longint;
begin
     FCursorBevelOuter := Bevel;
     for I := 1 to 8 do FPanels[ I ].BevelOuter := Bevel;
end;

{ ============================================================================
  REDIMENTIONNEMENT
  ============================================================================ }
procedure TMoveAndResize.ResizeInit( Panel : TPanel; var P : TPoint;
                                     var INewLeft, INewTop : Longint;
                                     var IControlLeft, IControlTop, IControlWidth, IControlHeight : Longint );
begin
     GetCursorPos( P );
     INewLeft := Panel.Left + P.X - Panel.ClientOrigin.X - PosX;
     INewTop := Panel.Top + P.Y - Panel.ClientOrigin.Y - PosY;
     IControlLeft := FControl.Left;
     IControlTop := FControl.Top;
     IControlWidth := FControl.Width;
     IControlHeight := FControl.Height;
end;

procedure TMoveAndResize.ResizeDone( IControlLeft, IControlTop, IControlWidth, IControlHeight : Longint );
begin
     if    ( IControlLeft <> FControl.Left )
        or ( IControlTop <> FControl.Top )
        or ( IControlWidth <> FControl.Width )
        or ( IControlHeight <> FControl.Height ) then
        begin // Mise à jour affichage
        FControl.SetBounds( IControlLeft, IControlTop, IControlWidth, IControlHeight );
        if FRedrawing
           then FControl.Update; // Invalidate déjà appelé par SetBounds
        ShowCursors;
        if Assigned( FOnResize )
           then FOnResize( Self );
        end;
end;

{ ============================================================================
  DEPLACEMENTS
  ============================================================================ }
procedure TMoveAndResize.BasGaucheMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
   P : TPoint;
   INewLeft, INewTop : Longint;
   IControlLeft, IControlTop, IControlWidth, IControlHeight : Longint;
begin
     if ssLeft in Shift then
        begin
        ResizeInit( FPanelBasGauche, P, INewLeft, INewTop, IControlLeft, IControlTop, IControlWidth, IControlHeight );
        if ( INewTop < FControl.Parent.ClientHeight - FCursorHeight2 )
           and ( INewTop - FPanelHaut.Top > FMinHeight - 1 ) then
           begin // Repositionnement bas
           IControlHeight := INewTop - FPanelHaut.Top;
           end;
        if ( INewLeft + FCursorWidth2 + FMinWidth - 1 < IControlLeft + IControlWidth )
           and ( INewLeft >= - FCursorWidth2 ) then
           begin // Repositionnement gauche
           IControlLeft := INewLeft + FCursorWidth2;
           IControlWidth := FPanelDroit.Left - INewLeft;
           end;
        ResizeDone( IControlLeft, IControlTop, IControlWidth, IControlHeight );
        end;
end;

procedure TMoveAndResize.GaucheMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
   P : TPoint;
   INewLeft, INewTop : Longint;
   IControlLeft, IControlTop, IControlWidth, IControlHeight : Longint;
begin
     if ssLeft in Shift then
        begin
        ResizeInit( FPanelGauche, P, INewLeft, INewTop, IControlLeft, IControlTop, IControlWidth, IControlHeight );
        if ( INewLeft + FCursorWidth2 + FMinWidth - 1 < IControlLeft + IControlWidth )
           and ( INewLeft >= - FCursorWidth2 ) then
           begin // Repositionnement gauche
           IControlLeft := INewLeft + FCursorWidth2;
           IControlWidth := FPanelDroit.Left - INewLeft;
           end;
        ResizeDone( IControlLeft, IControlTop, IControlWidth, IControlHeight );
        end;
end;

procedure TMoveAndResize.HautGaucheMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
   P : TPoint;
   INewLeft, INewTop : Longint;
   IControlLeft, IControlTop, IControlWidth, IControlHeight : Longint;
begin
     if ssLeft in Shift then
        begin
        ResizeInit( FPanelHautGauche, P, INewLeft, INewTop, IControlLeft, IControlTop, IControlWidth, IControlHeight );
        if ( INewTop + FCursorHeight2 + FMinHeight - 1 < IControlTop + IControlHeight )
           and ( INewTop >= - FCursorHeight2 ) then
           begin // Repositionnement haut
           IControlTop := INewTop + FCursorHeight2;
           IControlHeight := FPanelBas.Top - INewTop;
           end;
        if ( INewLeft + FCursorWidth2 + FMinWidth - 1 < IControlLeft + IControlWidth )
           and ( INewLeft >= - FCursorWidth2 ) then
           begin // Repositionnement gauche
           IControlLeft := INewLeft + FCursorWidth2;
           IControlWidth := FPanelDroit.Left - INewLeft;
           end;
        ResizeDone( IControlLeft, IControlTop, IControlWidth, IControlHeight );
        end;
end;

procedure TMoveAndResize.HautMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
   P : TPoint;
   INewLeft, INewTop : Longint;
   IControlLeft, IControlTop, IControlWidth, IControlHeight : Longint;
begin
     if ssLeft in Shift then
        begin
        ResizeInit( FPanelHaut, P, INewLeft, INewTop, IControlLeft, IControlTop, IControlWidth, IControlHeight );
        if ( INewTop + FCursorHeight2 + FMinHeight - 1 < IControlTop + IControlHeight )
           and ( INewTop >= - FCursorHeight2 ) then
           begin // Repositionnement haut
           IControlTop := INewTop + FCursorHeight2;
           IControlHeight := FPanelBas.Top - INewTop;
           end;
        ResizeDone( IControlLeft, IControlTop, IControlWidth, IControlHeight );
        end;
end;

procedure TMoveAndResize.HautDroitMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
   P : TPoint;
   INewLeft, INewTop : Longint;
   IControlLeft, IControlTop, IControlWidth, IControlHeight : Longint;
begin
     if ssLeft in Shift then
        begin
        ResizeInit( FPanelHautDroit, P, INewLeft, INewTop, IControlLeft, IControlTop, IControlWidth, IControlHeight );
        if ( INewTop + FCursorHeight2 + FMinHeight - 1 < IControlTop + IControlHeight )
           and ( INewTop >= - FCursorHeight2 ) then
           begin // Repositionnement haut
           IControlTop := INewTop + FCursorHeight2;
           IControlHeight := FPanelBas.Top - INewTop;
           end;
        if ( INewLeft > FPanelHautGauche.Left + FMinWidth + 1 )
           and ( INewLeft < FControl.Parent.ClientWidth - FCursorWidth2 ) then
           begin // Repositionnement droit
           IControlWidth := INewLeft - IControlLeft;
           end;
        ResizeDone( IControlLeft, IControlTop, IControlWidth, IControlHeight );
        end;
end;

procedure TMoveAndResize.DroitMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
   P : TPoint;
   INewLeft, INewTop : Longint;
   IControlLeft, IControlTop, IControlWidth, IControlHeight : Longint;
begin
     if ssLeft in Shift then
        begin
        ResizeInit( FPanelDroit, P, INewLeft, INewTop, IControlLeft, IControlTop, IControlWidth, IControlHeight );
        if ( INewLeft > FPanelHautGauche.Left + FMinWidth + 1 )
           and ( INewLeft < FControl.Parent.ClientWidth - FCursorWidth2 ) then
           begin // Repositionnement droit
           IControlWidth := INewLeft - IControlLeft;
           end;
        ResizeDone( IControlLeft, IControlTop, IControlWidth, IControlHeight );
        end;
end;

procedure TMoveAndResize.BasDroitMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
   P : TPoint;
   INewLeft, INewTop : Longint;
   IControlLeft, IControlTop, IControlWidth, IControlHeight : Longint;
begin
     if ssLeft in Shift then
        begin
        ResizeInit( FPanelBasDroit, P, INewLeft, INewTop, IControlLeft, IControlTop, IControlWidth, IControlHeight );
        if ( INewTop < FControl.Parent.ClientHeight - FCursorHeight2 )
           and ( INewTop - FPanelHaut.Top > FMinHeight - 1 ) then
           begin // Repositionnement bas
           IControlHeight := INewTop - FPanelHaut.Top;
           end;
        if ( INewLeft > FPanelHautGauche.Left + FMinWidth + 1 )
           and ( INewLeft < FControl.Parent.ClientWidth - FCursorWidth2 ) then
           begin // Repositionnement droit
           IControlWidth := INewLeft - IControlLeft;
           end;
        ResizeDone( IControlLeft, IControlTop, IControlWidth, IControlHeight );
        end;
end;

procedure TMoveAndResize.BasMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
   P : TPoint;
   INewLeft, INewTop : Longint;
   IControlLeft, IControlTop, IControlWidth, IControlHeight : Longint;
begin
     GetCursorPos( P );
     if ssLeft in Shift then
        begin
        ResizeInit( FPanelBas, P, INewLeft, INewTop, IControlLeft, IControlTop, IControlWidth, IControlHeight );
        if ( INewTop < FControl.Parent.ClientHeight - FCursorHeight2 )
           and ( INewTop - FPanelHaut.Top > FMinHeight - 1 ) then
           begin // Repositionnement bas
           IControlHeight := INewTop - FPanelHaut.Top;
           end;
        ResizeDone( IControlLeft, IControlTop, IControlWidth, IControlHeight );
        end;
end;

end.
