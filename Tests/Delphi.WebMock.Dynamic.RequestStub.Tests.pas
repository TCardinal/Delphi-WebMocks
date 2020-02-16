{******************************************************************************}
{                                                                              }
{           Delphi-WebMocks                                                    }
{                                                                              }
{           Copyright (c) 2020 Richard Hatherall                               }
{                                                                              }
{           richard@appercept.com                                              }
{           https://appercept.com                                              }
{                                                                              }
{******************************************************************************}
{                                                                              }
{   Licensed under the Apache License, Version 2.0 (the "License");            }
{   you may not use this file except in compliance with the License.           }
{   You may obtain a copy of the License at                                    }
{                                                                              }
{       http://www.apache.org/licenses/LICENSE-2.0                             }
{                                                                              }
{   Unless required by applicable law or agreed to in writing, software        }
{   distributed under the License is distributed on an "AS IS" BASIS,          }
{   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   }
{   See the License for the specific language governing permissions and        }
{   limitations under the License.                                             }
{                                                                              }
{******************************************************************************}

unit Delphi.WebMock.Dynamic.RequestStub.Tests;

interface

uses
  DUnitX.TestFramework,
  Delphi.WebMock.Dynamic.RequestStub;

type
  [TestFixture]
  TWebMockDynamicRequestStubTests = class(TObject)
  private
    StubbedRequest: TWebMockDynamicRequestStub;
  public
    [Test]
    procedure Class_Always_ImplementsIWebMockRequestStub;
    [Test]
    procedure IsMatch_WhenInitializedWithFunctionReturningTrue_ReturnsTrue;
    [Test]
    procedure IsMatch_WhenInitializedWithFunctionReturningFalse_ReturnsFalse;
    [Test]
    procedure GetResponse_Always_GetsResponse;
    [Test]
    procedure SetResponse_Always_SetsResponse;
    [Test]
    procedure ToRespond_Always_ReturnsAResponseStub;
    [Test]
    procedure ToRespond_WithNoArguments_DoesNotRaiseException;
    [Test]
    procedure ToRespond_WithNoArguments_DoesNotChangeStatus;
    [Test]
    procedure ToString_Always_ReturnsAStringDescription;
  end;

implementation

uses
  Delphi.WebMock.HTTP.Messages, Delphi.WebMock.HTTP.Request,
  Delphi.WebMock.RequestStub, Delphi.WebMock.Response,
  Delphi.WebMock.ResponseStatus,
  Mock.Indy.HTTPRequestInfo,
  IdCustomHTTPServer;

{ TWebMockDynamicRequestStubTests }

procedure TWebMockDynamicRequestStubTests.Class_Always_ImplementsIWebMockRequestStub;
var
  LSubject: IInterface;
begin
  LSubject := TWebMockDynamicRequestStub.Create(
    function(ARequest: IWebMockHTTPRequest): Boolean
    begin
      Result := False;
    end
  );

  Assert.Implements<IWebMockRequestStub>(LSubject);
end;

procedure TWebMockDynamicRequestStubTests.GetResponse_Always_GetsResponse;
begin
  Assert.IsTrue(StubbedRequest.GetResponse <> nil, 'GetResponse should return a response');
end;

procedure TWebMockDynamicRequestStubTests.IsMatch_WhenInitializedWithFunctionReturningFalse_ReturnsFalse;
var
  LRequestInfo: TIdHTTPRequestInfo;
  LRequest: IWebMockHTTPRequest;
begin
  LRequestInfo := TMockIdHTTPRequestInfo.Mock('GET', '/');
  LRequest := TWebMockHTTPRequest.Create(LRequestInfo);

  StubbedRequest := TWebMockDynamicRequestStub.Create(
    function(ARequest: IWebMockHTTPRequest): Boolean
    begin
      Result := False;
    end
  );

  Assert.IsFalse(StubbedRequest.IsMatch(LRequest));
end;

procedure TWebMockDynamicRequestStubTests.IsMatch_WhenInitializedWithFunctionReturningTrue_ReturnsTrue;
var
  LRequestInfo: TIdHTTPRequestInfo;
  LRequest: IWebMockHTTPRequest;
begin
  LRequestInfo := TMockIdHTTPRequestInfo.Mock('GET', '/');
  LRequest := TWebMockHTTPRequest.Create(LRequestInfo);

  StubbedRequest := TWebMockDynamicRequestStub.Create(
    function(ARequest: IWebMockHTTPRequest): Boolean
    begin
      Result := True;
    end
  );

  Assert.IsTrue(StubbedRequest.IsMatch(LRequest));
end;

procedure TWebMockDynamicRequestStubTests.SetResponse_Always_SetsResponse;
var
  LResponse: TWebMockResponse;
begin
  LResponse := TWebMockResponse.Create;

  StubbedRequest.SetResponse(LResponse);

  Assert.AreSame(LResponse, StubbedRequest.Response, 'SetResponse should set Response');
end;

procedure TWebMockDynamicRequestStubTests.ToRespond_Always_ReturnsAResponseStub;
begin
  Assert.IsTrue(StubbedRequest.ToRespond is TWebMockResponse);
end;

procedure TWebMockDynamicRequestStubTests.ToRespond_WithNoArguments_DoesNotChangeStatus;
var
  LExpectedStatus: TWebMockResponseStatus;
begin
  LExpectedStatus := StubbedRequest.Response.Status;

  StubbedRequest.ToRespond;

  Assert.AreSame(LExpectedStatus, StubbedRequest.Response.Status);
end;

procedure TWebMockDynamicRequestStubTests.ToRespond_WithNoArguments_DoesNotRaiseException;
begin
  Assert.WillNotRaiseAny(
    procedure
    begin
      StubbedRequest.ToRespond;
    end
  );
end;

procedure TWebMockDynamicRequestStubTests.ToString_Always_ReturnsAStringDescription;
begin
  Assert.IsTrue(Length(StubbedRequest.ToString) > 0, 'ToString should return a description');
end;

initialization
  TDUnitX.RegisterTestFixture(TWebMockDynamicRequestStubTests);
end.
