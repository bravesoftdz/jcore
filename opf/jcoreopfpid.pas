(*
  JCore, OPF Persistence Identity Class
  Copyright (C) 2014 Joao Morais

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit JCoreOPFPID;

{$I jcore.inc}

interface

uses
  JCoreOPFID;

type

  { TODO :
    Sessions from different configurations need different PIDs,
    iow, the same entity may be persistent to a configuration
    and nonpersistent to another one }

  { TJCoreOPFPID }

  TJCoreOPFPID = class(TInterfacedObject, IJCoreOPFPID)
  private
    FEntity: TObject;
    FIsPersistent: Boolean;
    FOID: TJCoreOPFOID;
    FOwner: IJCoreOPFPID;
    function GetEntity: TObject;
    function GetIsPersistent: Boolean;
    function GetOID: TJCoreOPFOID;
    function GetOwner: IJCoreOPFPID;
    procedure SetOwner(const AValue: IJCoreOPFPID);
  public
    constructor Create(const AEntity: TObject);
    destructor Destroy; override;
    procedure AssignOID(const AOID: TJCoreOPFOID);
    procedure Commit;
    procedure ReleaseOID(const AOID: TJCoreOPFOID);
    property IsPersistent: Boolean read GetIsPersistent;
    property Entity: TObject read GetEntity;
    property OID: TJCoreOPFOID read FOID;
    property Owner: IJCoreOPFPID read GetOwner write SetOwner;
  end;

implementation

uses
  sysutils,
  JCoreClasses,
  JCoreOPFException;

{ TJCoreOPFPID }

function TJCoreOPFPID.GetEntity: TObject;
begin
  Result := FEntity;
end;

function TJCoreOPFPID.GetIsPersistent: Boolean;
begin
  Result := FIsPersistent;
end;

function TJCoreOPFPID.GetOID: TJCoreOPFOID;
begin
  Result := FOID;
end;

function TJCoreOPFPID.GetOwner: IJCoreOPFPID;
begin
  Result := FOwner;
end;

procedure TJCoreOPFPID.SetOwner(const AValue: IJCoreOPFPID);
begin
  if not Assigned(AValue) then
    FOwner := nil
  else if not Assigned(FOwner) then
  begin
    { TODO : Check circular reference }
    FOwner := AValue;
  end else if FOwner <> AValue then
    raise EJCoreOPFObjectAlreadyOwned.Create(Entity.ClassName, FOwner.Entity.ClassName);
end;

constructor TJCoreOPFPID.Create(const AEntity: TObject);
begin
  if not Assigned(AEntity) then
    raise EJCoreNilPointerException.Create;
  inherited Create;
  FEntity := AEntity;
  FIsPersistent := False;
end;

destructor TJCoreOPFPID.Destroy;
begin
  FreeAndNil(FOID);
  inherited Destroy;
end;

procedure TJCoreOPFPID.AssignOID(const AOID: TJCoreOPFOID);
begin
  if IsPersistent then
    raise EJCoreOPFCannotAssignOIDPersistent.Create;
  FreeAndNil(FOID);
  FOID := AOID;
end;

procedure TJCoreOPFPID.Commit;
begin
  FIsPersistent := Assigned(OID);
end;

procedure TJCoreOPFPID.ReleaseOID(const AOID: TJCoreOPFOID);
begin
  { TODO : Used to release the OID if an exception raises just after the OID
           was assigned. A refcounted object (intf or a jcore managed obj) is
           a better approach }
  if FOID = AOID then
    FOID := nil;
end;

end.

