function varargout = tela_controle_mm(varargin)
% TELA_CONTROLE_MM M-file for tela_controle_mm.fig
%      TELA_CONTROLE_MM, by itself, creates a new TELA_CONTROLE_MM or raises the existing
%      singleton*.
%
%      H = TELA_CONTROLE_MM returns the handle to a new TELA_CONTROLE_MM or the handle to
%      the existing singleton*.
%
%      TELA_CONTROLE_MM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TELA_CONTROLE_MM.M with the given input arguments.
%
%      TELA_CONTROLE_MM('Property','Value',...) creates a new TELA_CONTROLE_MM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before tela_controle_mm_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to tela_controle_mm_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help tela_controle_mm

% Last Modified by GUIDE v2.5 18-Jul-2015 06:31:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @tela_controle_mm_OpeningFcn, ...
                   'gui_OutputFcn',  @tela_controle_mm_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before tela_controle_mm is made visible.
function tela_controle_mm_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to tela_controle_mm (see VARARGIN)

% Choose default command line output for tela_controle_mm
handles.output = hObject;

tabelaPosLimitesData = [[2432 480 1405 480];[2256 768 1798 2256];[2208 800 2208 959];[2480 528 1251 1836];[2432 512 1472 1472];[2000 416 (2000+416)/2 2000]];
set(handles.tabelaPosLimites,'Data',tabelaPosLimitesData);
global seqEmExecucao
seqEmExecucao = false;

positionFig = get(handles.figure1,'Position');
positionFig(3) = 112;
set(handles.figure1,'Position',positionFig);

% Update handles structure
guidata(hObject, handles);
%clear all;
clc

% UIWAIT makes tela_controle_mm wait for user response (see UIRESUME)
% uiwait(handles.figure1);



% --- Outputs from this function are returned to the command line.
function varargout = tela_controle_mm_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in botaoAbrirPortaSerial.
function botaoAbrirPortaSerial_Callback(hObject, eventdata, handles)
% hObject    handle to botaoAbrirPortaSerial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

contents = cellstr(get(handles.popupPortasSeriaisDisp,'String')); 
handles.portaSelecionada = contents{get(handles.popupPortasSeriaisDisp,'Value')};

contents = cellstr(get(handles.popupBaudRate,'String'));
handles.baudRate = str2double(contents{get(handles.popupBaudRate,'Value')});

contents = cellstr(get(handles.popupParidade,'String'));
handles.paridade = contents{get(handles.popupParidade,'Value')};

contents = cellstr(get(handles.popupBitsDeDados,'String'));
handles.bitsDeDados = str2double(contents{get(handles.popupBitsDeDados,'Value')});

contents = cellstr(get(handles.popupBitDeParada,'String'));
handles.bitsDeParada = str2double(contents{get(handles.popupBitDeParada,'Value')});

handles.serConn = serial(handles.portaSelecionada);
set(handles.serConn,'BaudRate',handles.baudRate,'Parity',handles.paridade,'DataBits',handles.bitsDeDados,'StopBits',handles.bitsDeParada,'Timeout',1);

try
    fopen(handles.serConn);
    
    configuracoesIniciais(hObject, eventdata, handles);
    
    HabilitarComponentesConn('On', hObject, handles);
    
catch e
    fclose(handles.serConn);
    delete(handles.serConn);
    errordlg(e.message);
end
guidata(hObject, handles);


%---
function configuracoesIniciais(hObject, eventdata, handles)

velocidades = [16 8 8 8 -1 -1];
aceleracoes = [-1 -1 -1 -1 -1 -1];
juntas = ['J0'; 'J1'; 'J2'; 'J3'; 'J4'; 'GR'];
for i=1:6
    comandoVELOuACL('VEL', juntas(i,:), velocidades(i), hObject, handles);
    comandoVELOuACL('ACL', juntas(i,:), aceleracoes(i), hObject, handles);
end

comandoObterPosicoesAtuais(hObject, handles);


%--- estadoHab = 'On' ou 'Off'
function HabilitarComponentes(estadoHab, hObject, handles)
set(handles.botaoFecharPortaSerial, 'Enable',estadoHab);
set(handles.botaoAbrirGarra, 'Enable',estadoHab);
set(handles.botaoFecharGarra, 'Enable',estadoHab);
set(handles.botaoGarraSemiaberta, 'Enable',estadoHab);
set(handles.botaoGirarGarraMais90, 'Enable',estadoHab);
set(handles.botaoGirarGarraMenos90, 'Enable',estadoHab);
set(handles.botaoGarraPosNeutra, 'Enable',estadoHab);
set(handles.botaoPosRepouso, 'Enable',estadoHab);
set(handles.botaoDesligaServos, 'Enable',estadoHab);
set(handles.botaoPosNeutraCTZ, 'Enable',estadoHab);
set(handles.botaoPosNeutraJST, 'Enable',estadoHab);
juntas = ['J0';'J1';'J2';'J3';'J4';'GR'];
for i = 1:6
    set(handles.(['edt' juntas(i,:) 'Alvo']), 'Enable', estadoHab);
    set(handles.(['edt' juntas(i,:) 'Vel']), 'Enable', estadoHab);
    set(handles.(['edt' juntas(i,:) 'Acl']), 'Enable', estadoHab);
end
set(handles.botaoObterPosicoes, 'Enable', estadoHab);
set(handles.botaoMover, 'Enable', estadoHab);
set(handles.botaoMoverComVelAcl, 'Enable', estadoHab);
set(handles.tabelaPosLimites, 'Enable', estadoHab);
set(handles.listSequenciaComandos, 'Enable', estadoHab);
set(handles.botaoAdicionarComando, 'Enable', estadoHab);
set(handles.botaoAdicionarPosCorrente, 'Enable', estadoHab);
set(handles.botaoEditarComando, 'Enable', estadoHab);
set(handles.botaoRemoverComando, 'Enable', estadoHab);
set(handles.botaoCarregarSeq, 'Enable', estadoHab);
set(handles.botaoSalvarSeq, 'Enable', estadoHab);
set(handles.botaoExecutarSeq, 'Enable', estadoHab);
set(handles.botaoPararSeq, 'Enable', estadoHab);
set(handles.botaoComandoUp, 'Enable', estadoHab);
set(handles.botaoComandoDown, 'Enable', estadoHab);

guidata(hObject, handles);


%--- estadoHab = 'On' ou 'Off'
function HabilitarComponentesConn(estadoHab, hObject, handles)
if strcmp(estadoHab,'On')
    estadoNaoHab = 'Off';
else
    estadoNaoHab = 'On';
end
set(handles.botaoAbrirPortaSerial, 'Enable',estadoNaoHab);
HabilitarComponentes(estadoHab, hObject, handles);
guidata(hObject, handles);


% --- Executes on selection change in popupPortasSeriaisDisp.
function popupPortasSeriaisDisp_Callback(hObject, eventdata, handles)
% hObject    handle to popupPortasSeriaisDisp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupPortasSeriaisDisp contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupPortasSeriaisDisp


% --- Executes during object creation, after setting all properties.
function popupPortasSeriaisDisp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupPortasSeriaisDisp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%Alimenta o popup com as portas seriais disponíveis
serialInfo = instrhwinfo('serial');
set(hObject,'String',serialInfo.AvailableSerialPorts);


% --- Executes on button press in botaoFecharPortaSerial.
function botaoFecharPortaSerial_Callback(hObject, eventdata, handles)
% hObject    handle to botaoFecharPortaSerial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles, 'serConn')
    if isvalid(handles.serConn)
        fclose(handles.serConn);
        delete(handles.serConn);
    end
end
HabilitarComponentesConn('Off', hObject, handles)
guidata(hObject, handles);


% --- Executes on selection change in popupBaudRate.
function popupBaudRate_Callback(hObject, eventdata, handles)
% hObject    handle to popupBaudRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupBaudRate contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupBaudRate


% --- Executes during object creation, after setting all properties.
function popupBaudRate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupBaudRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

set(hObject,'String',{'110'; '300'; '600'; '1200'; '2400'; '4800'; '9600'; '14400'; '19200'; '38400'; '57600'; '115200'; '128000'; '256000'});
set(hObject,'Value',7);

% --- Executes on selection change in popupParidade.
function popupParidade_Callback(hObject, eventdata, handles)
% hObject    handle to popupParidade (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupParidade contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupParidade


% --- Executes during object creation, after setting all properties.
function popupParidade_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupParidade (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

set(hObject,'String',{'none'; 'odd'; 'even'; 'mark'; 'space'});
set(hObject,'Value',1);


% --- Executes on selection change in popupBitsDeDados.
function popupBitsDeDados_Callback(hObject, eventdata, handles)
% hObject    handle to popupBitsDeDados (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupBitsDeDados contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupBitsDeDados


% --- Executes during object creation, after setting all properties.
function popupBitsDeDados_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupBitsDeDados (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

set(hObject,'String',{'5'; '6'; '7'; '8'});
set(hObject,'Value',4);


% --- Executes on selection change in popupBitDeParada.
function popupBitDeParada_Callback(hObject, eventdata, handles)
% hObject    handle to popupBitDeParada (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupBitDeParada contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupBitDeParada


% --- Executes during object creation, after setting all properties.
function popupBitDeParada_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupBitDeParada (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

set(hObject,'String',{'1'; '1.5'; '2'});
set(hObject,'Value',1);


% --- Executes on button press in botaoAbrirGarra.
function botaoAbrirGarra_Callback(hObject, eventdata, handles)
% hObject    handle to botaoAbrirGarra (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
comandoAbrirGarra(hObject, handles);
guidata(hObject, handles);


% --- Executes on button press in botaoFecharGarra.
function botaoFecharGarra_Callback(hObject, eventdata, handles)
% hObject    handle to botaoFecharGarra (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
comandoFecharGarra(hObject, handles);
guidata(hObject, handles);


% --- Executes on button press in botaoGarraSemiaberta.
function botaoGarraSemiaberta_Callback(hObject, eventdata, handles)
% hObject    handle to botaoGarraSemiaberta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
comandoGarraSemiAberta(hObject, handles);
guidata(hObject, handles);



% --- Executes on button press in botaoGirarGarraMais90.
function botaoGirarGarraMais90_Callback(hObject, eventdata, handles)
% hObject    handle to botaoGirarGarraMais90 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tabelaPosLimitesData = get(handles.tabelaPosLimites,'Data');
alvo = tabelaPosLimitesData(5,1);
%alvo
set(handles.edtJ4Alvo, 'String',num2str(alvo));
drawnow;
comandoPosicionarJunta('J4', alvo, hObject, handles);


% --- Executes on button press in botaoGirarGarraMenos90.
function botaoGirarGarraMenos90_Callback(hObject, eventdata, handles)
% hObject    handle to botaoGirarGarraMenos90 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tabelaPosLimitesData = get(handles.tabelaPosLimites,'Data');
alvo = tabelaPosLimitesData(5,2);
%alvo
set(handles.edtJ4Alvo, 'String',num2str(alvo));
drawnow;
comandoPosicionarJunta('J4', alvo, hObject, handles);


% --- Executes on button press in botaoGarraPosNeutra.
function botaoGarraPosNeutra_Callback(hObject, eventdata, handles)
% hObject    handle to botaoGarraPosNeutra (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tabelaPosLimitesData = get(handles.tabelaPosLimites,'Data');
alvo = tabelaPosLimitesData(5,3);
%alvo
set(handles.edtJ4Alvo, 'String',num2str(alvo));
drawnow;
comandoPosicionarJunta('J4', alvo, hObject, handles);


% --- Executes on button press in botaoPosRepouso.
function botaoPosRepouso_Callback(hObject, eventdata, handles)
% hObject    handle to botaoPosRepouso (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
comandoRepouso(hObject, handles);


% --- Executes on button press in botaoDesligaServos.
function botaoDesligaServos_Callback(hObject, eventdata, handles)
% hObject    handle to botaoDesligaServos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
comandoRepouso(hObject, handles);
%pause(10)
comandoDesligarServos(hObject, handles);
guidata(hObject, handles);


% --- Executes on button press in botaoPosNeutraCTZ.
function botaoPosNeutraCTZ_Callback(hObject, eventdata, handles)
% hObject    handle to botaoPosNeutraCTZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

comandoCTZ('J0', hObject, handles);
%pause(0.4)
comandoCTZ('J1', hObject, handles);
%pause(0.4)
comandoCTZ('J2', hObject, handles);
%pause(0.4)
comandoCTZ('J3', hObject, handles);
%pause(0.4)
comandoCTZ('J4', hObject, handles);
%pause(0.4)
comandoCTZ('GR', hObject, handles);
guidata(hObject, handles);


% --- Executes on button press in botaoPosNeutraJST.
function botaoPosNeutraJST_Callback(hObject, eventdata, handles)
% hObject    handle to botaoPosNeutraJST (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
juntas = ['J0'; 'J1'; 'J2'; 'J3'; 'J4'; 'GR'];
tabelaPosLimitesData = get(handles.tabelaPosLimites,'Data');
for i=1:6
    alvo = tabelaPosLimitesData(i,3);
    campoEditAlvo = ['edt' juntas(i,:) 'Alvo'];
    set(handles.(campoEditAlvo),'String',num2str(alvo));
    drawnow;
end
%Atual
comandoPosicionarTodasJuntas(hObject, handles);



% --- Executes on button press in botaoObterPosicoes.
function botaoObterPosicoes_Callback(hObject, eventdata, handles)
% hObject    handle to botaoObterPosicoes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
comandoObterPosicoesAtuais(hObject, handles)

% --- Executes on button press in botaoMover.
function botaoMover_Callback(hObject, eventdata, handles)
% hObject    handle to botaoMover (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
comandoPosicionarTodasJuntas(hObject, handles);


% --- Executes on button press in botaoMoverComVelAcl.
function botaoMoverComVelAcl_Callback(hObject, eventdata, handles)
% hObject    handle to botaoMoverComVelAcl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
comandoPosicionarTodasJuntas(hObject, handles);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles, 'serConn')
    if isvalid(handles.serConn)
        fclose(handles.serConn);
        delete(handles.serConn);
    end
end
% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes on button press in botaoConfiguracoes.
function botaoConfiguracoes_Callback(hObject, eventdata, handles)
% hObject    handle to botaoConfiguracoes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(strcmp(get(hObject,'String'),'Configurações...'))
    positionFig = get(handles.figure1,'Position');
    positionFig(3) = 204;
    set(handles.figure1,'Position',positionFig);
    set(hObject,'String','Fechar Config.');
else
    positionFig = get(handles.figure1,'Position');
    positionFig(3) = 112;
    set(handles.figure1,'Position',positionFig);
    set(hObject,'String','Configurações...');
end



function edtJ0Alvo_Callback(hObject, eventdata, handles)
% hObject    handle to edtJ0Alvo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtJ0Alvo as text
%        str2double(get(hObject,'String')) returns contents of edtJ0Alvo as a double


% --- Executes during object creation, after setting all properties.
function edtJ0Alvo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtJ0Alvo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtJ1Alvo_Callback(hObject, eventdata, handles)
% hObject    handle to edtJ1Alvo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtJ1Alvo as text
%        str2double(get(hObject,'String')) returns contents of edtJ1Alvo as a double


% --- Executes during object creation, after setting all properties.
function edtJ1Alvo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtJ1Alvo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtJ2Alvo_Callback(hObject, eventdata, handles)
% hObject    handle to edtJ2Alvo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtJ2Alvo as text
%        str2double(get(hObject,'String')) returns contents of edtJ2Alvo as a double


% --- Executes during object creation, after setting all properties.
function edtJ2Alvo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtJ2Alvo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtJ3Alvo_Callback(hObject, eventdata, handles)
% hObject    handle to edtJ3Alvo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtJ3Alvo as text
%        str2double(get(hObject,'String')) returns contents of edtJ3Alvo as a double


% --- Executes during object creation, after setting all properties.
function edtJ3Alvo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtJ3Alvo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtJ4Alvo_Callback(hObject, eventdata, handles)
% hObject    handle to edtJ4Alvo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtJ4Alvo as text
%        str2double(get(hObject,'String')) returns contents of edtJ4Alvo as a double


% --- Executes during object creation, after setting all properties.
function edtJ4Alvo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtJ4Alvo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtGRAlvo_Callback(hObject, eventdata, handles)
% hObject    handle to edtGRAlvo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtGRAlvo as text
%        str2double(get(hObject,'String')) returns contents of edtGRAlvo as a double


% --- Executes during object creation, after setting all properties.
function edtGRAlvo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtGRAlvo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtJ0Atual_Callback(hObject, eventdata, handles)
% hObject    handle to edtJ0Atual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtJ0Atual as text
%        str2double(get(hObject,'String')) returns contents of edtJ0Atual as a double


% --- Executes during object creation, after setting all properties.
function edtJ0Atual_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtJ0Atual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtJ1Atual_Callback(hObject, eventdata, handles)
% hObject    handle to edtJ1Atual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtJ1Atual as text
%        str2double(get(hObject,'String')) returns contents of edtJ1Atual as a double


% --- Executes during object creation, after setting all properties.
function edtJ1Atual_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtJ1Atual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtJ2Atual_Callback(hObject, eventdata, handles)
% hObject    handle to edtJ2Atual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtJ2Atual as text
%        str2double(get(hObject,'String')) returns contents of edtJ2Atual as a double


% --- Executes during object creation, after setting all properties.
function edtJ2Atual_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtJ2Atual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtJ3Atual_Callback(hObject, eventdata, handles)
% hObject    handle to edtJ3Atual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtJ3Atual as text
%        str2double(get(hObject,'String')) returns contents of edtJ3Atual as a double


% --- Executes during object creation, after setting all properties.
function edtJ3Atual_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtJ3Atual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtJ4Atual_Callback(hObject, eventdata, handles)
% hObject    handle to edtJ4Atual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtJ4Atual as text
%        str2double(get(hObject,'String')) returns contents of edtJ4Atual as a double


% --- Executes during object creation, after setting all properties.
function edtJ4Atual_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtJ4Atual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtGRAtual_Callback(hObject, eventdata, handles)
% hObject    handle to edtGRAtual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtGRAtual as text
%        str2double(get(hObject,'String')) returns contents of edtGRAtual as a double


% --- Executes during object creation, after setting all properties.
function edtGRAtual_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtGRAtual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtJ0Vel_Callback(hObject, eventdata, handles)
% hObject    handle to edtJ0Vel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtJ0Vel as text
%        str2double(get(hObject,'String')) returns contents of edtJ0Vel as a double


% --- Executes during object creation, after setting all properties.
function edtJ0Vel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtJ0Vel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtJ1Vel_Callback(hObject, eventdata, handles)
% hObject    handle to edtJ1Vel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtJ1Vel as text
%        str2double(get(hObject,'String')) returns contents of edtJ1Vel as a double


% --- Executes during object creation, after setting all properties.
function edtJ1Vel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtJ1Vel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtJ2Vel_Callback(hObject, eventdata, handles)
% hObject    handle to edtJ2Vel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtJ2Vel as text
%        str2double(get(hObject,'String')) returns contents of edtJ2Vel as a double


% --- Executes during object creation, after setting all properties.
function edtJ2Vel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtJ2Vel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtJ3Vel_Callback(hObject, eventdata, handles)
% hObject    handle to edtJ3Vel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtJ3Vel as text
%        str2double(get(hObject,'String')) returns contents of edtJ3Vel as a double


% --- Executes during object creation, after setting all properties.
function edtJ3Vel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtJ3Vel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtJ4Vel_Callback(hObject, eventdata, handles)
% hObject    handle to edtJ4Vel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtJ4Vel as text
%        str2double(get(hObject,'String')) returns contents of edtJ4Vel as a double


% --- Executes during object creation, after setting all properties.
function edtJ4Vel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtJ4Vel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtGRVel_Callback(hObject, eventdata, handles)
% hObject    handle to edtGRVel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtGRVel as text
%        str2double(get(hObject,'String')) returns contents of edtGRVel as a double


% --- Executes during object creation, after setting all properties.
function edtGRVel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtGRVel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtJ0Acl_Callback(hObject, eventdata, handles)
% hObject    handle to edtJ0Acl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtJ0Acl as text
%        str2double(get(hObject,'String')) returns contents of edtJ0Acl as a double


% --- Executes during object creation, after setting all properties.
function edtJ0Acl_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtJ0Acl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtJ1Acl_Callback(hObject, eventdata, handles)
% hObject    handle to edtJ1Acl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtJ1Acl as text
%        str2double(get(hObject,'String')) returns contents of edtJ1Acl as a double


% --- Executes during object creation, after setting all properties.
function edtJ1Acl_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtJ1Acl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtJ2Acl_Callback(hObject, eventdata, handles)
% hObject    handle to edtJ2Acl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtJ2Acl as text
%        str2double(get(hObject,'String')) returns contents of edtJ2Acl as a double


% --- Executes during object creation, after setting all properties.
function edtJ2Acl_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtJ2Acl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtJ3Acl_Callback(hObject, eventdata, handles)
% hObject    handle to edtJ3Acl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtJ3Acl as text
%        str2double(get(hObject,'String')) returns contents of edtJ3Acl as a double


% --- Executes during object creation, after setting all properties.
function edtJ3Acl_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtJ3Acl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtJ4Acl_Callback(hObject, eventdata, handles)
% hObject    handle to edtJ4Acl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtJ4Acl as text
%        str2double(get(hObject,'String')) returns contents of edtJ4Acl as a double


% --- Executes during object creation, after setting all properties.
function edtJ4Acl_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtJ4Acl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtGRAcl_Callback(hObject, eventdata, handles)
% hObject    handle to edtGRAcl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtGRAcl as text
%        str2double(get(hObject,'String')) returns contents of edtGRAcl as a double


% --- Executes during object creation, after setting all properties.
function edtGRAcl_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtGRAcl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listSequenciaComandos.
function listSequenciaComandos_Callback(hObject, eventdata, handles)
% hObject    handle to listSequenciaComandos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listSequenciaComandos contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listSequenciaComandos


% --- Executes during object creation, after setting all properties.
function listSequenciaComandos_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listSequenciaComandos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in botaoAdicionarComando.
function botaoAdicionarComando_Callback(hObject, eventdata, handles)
% hObject    handle to botaoAdicionarComando (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
comando = inputdlg('Digite o novo comando entre colchetes ([]):', 'Novo Comando');
if isempty(comando)
    return
end
comandos = cellstr(get(handles.listSequenciaComandos,'String'));
tam = size(comandos);
tamSeqCom = tam(1);
index_selected = get(handles.listSequenciaComandos,'Value');

if tamSeqCom > 0 && ~isempty(index_selected)
    index_selected = get(handles.listSequenciaComandos,'Value');

    if index_selected == tamSeqCom
        comandos = [comandos; comando];
    else
        comandosAntes = comandos(1:index_selected);
        comandosDepois = comandos(index_selected+1:tamSeqCom);
        comandos = [comandosAntes; comando; comandosDepois];
    end
    index_selected = index_selected+1;
    set(handles.listSequenciaComandos,'String',comandos, 'Value', index_selected);
else
    comandos = comando;
    set(handles.listSequenciaComandos,'String',comandos,'Value',1);
end



% --- Executes on button press in botaoAdicionarPosCorrente.
function botaoAdicionarPosCorrente_Callback(hObject, eventdata, handles)
% hObject    handle to botaoAdicionarPosCorrente (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
juntas = ['J0'; 'J1'; 'J2'; 'J3'; 'J4'; 'GR'];
cmdJST = '[JSTA0000B0000C0000D0000E0000G0000]';
for i = 1:6
    % monta o JST
    alvo = str2double(get(handles.(['edt' juntas(i,:) 'Atual']),'String'));
    idxPosJunta = 6+5*(i-1);
    cmdJST(idxPosJunta:idxPosJunta+3) = sprintf('%04d',alvo);
end
cmdJSTcell = {cmdJST};
comandos = cellstr(get(handles.listSequenciaComandos,'String'));
tam = size(comandos);
index_selected = get(handles.listSequenciaComandos,'Value');
tamSeqCom = tam(1);
if tamSeqCom > 0 && ~isempty(index_selected)
    if index_selected == tamSeqCom
        comandos = [comandos; cmdJSTcell];
    else
        comandosAntes = comandos(1:index_selected);
        comandosDepois = comandos(index_selected+1:tamSeqCom);
        comandos = [comandosAntes; cmdJSTcell; comandosDepois];
    end
    index_selected = index_selected+1;
    set(handles.listSequenciaComandos,'String',comandos, 'Value', index_selected);
else
    comandos = cmdJSTcell;
    set(handles.listSequenciaComandos,'String',comandos, 'Value', 1);
end



% --- Executes on button press in botaoCarregarSeq.
function botaoCarregarSeq_Callback(hObject, eventdata, handles)
% hObject    handle to botaoCarregarSeq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile( ...
{'*.seq', 'Sequência de Comandos (*.seq)';...
 '*.txt','Arquivo Texto (*.txt)';
 '*.*',  'All Files (*.*)'},...
 'Carregar Sequência de Comandos');

if isequal(filename,0) || isequal(pathname,0)
    disp('Cancel');
else
    arquivo = [pathname, filename];
    permission = 'r'; % Open or create new file for reading and writing. Discard existing contents, if any.
    machineformat = 'n';
    encoding = 'US-ASCII';
    fileID = fopen(arquivo, permission, machineformat, encoding);
    comando = fgetl(fileID);
    tamSeqCom = 0;

    while ischar(comando)
        if tamSeqCom > 0
        %     item_selected = items{index_selected};
        %     display(item_selected);
              %index_selected = get(handles.listSequenciaComandos,'Value');
            comandos = [comandos; cellstr(comando)];
        else
            comandos = cellstr(comando);
        end
        tamSeqCom = tamSeqCom + 1;
        comando = fgetl(fileID);
    end
    set(handles.listSequenciaComandos,'String', comandos, 'Value', 1);
    fclose(fileID);
end



% --- Executes on button press in botaoSalvarSeq.
function botaoSalvarSeq_Callback(hObject, eventdata, handles)
% hObject    handle to botaoSalvarSeq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

comandos = get(handles.listSequenciaComandos,'String');
tam = size(comandos);
tamSeqCom = tam(1);
if tamSeqCom > 0
    [filename, pathname] = uiputfile( ...
    {'*.seq', 'Sequência de Comandos (*.seq)';...
     '*.txt','Arquivo Texto (*.txt)';
     '*.*',  'All Files (*.*)'},...
     'Salvar Sequência de Comandos');
    if isequal(filename,0) || isequal(pathname,0)
        disp('Cancel');
    else
        arquivo = [pathname, filename];
        permission = 'w+'; % Open or create new file for reading and writing. Discard existing contents, if any.
        machineformat = 'n';
        encoding = 'US-ASCII';
        fileID = fopen(arquivo, permission, machineformat, encoding);
    
%         item_selected = items{index_selected};
%         display(item_selected);
%           index_selected = get(handles.listSequenciaComandos,'Value');
        for j = 1:tamSeqCom
            comandoCorrente = comandos{j};
            fprintf(fileID,[comandoCorrente 13 10]);
        end
        
        fclose(fileID);
    end   
    
else
    disp('Sequência vazia');
end



% --- Executes on button press in botaoExecutarSeq.
function botaoExecutarSeq_Callback(hObject, eventdata, handles)
% hObject    handle to botaoExecutarSeq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global seqEmExecucao;
seqEmExecucao = true;
guidata(hObject, handles);
comandos = get(handles.listSequenciaComandos,'String');
tam = size(comandos);
tamSeqCom = tam(1);
if tamSeqCom > 0
%     item_selected = items{index_selected};
%     display(item_selected);
      %index_selected = get(handles.listSequenciaComandos,'Value');
    for j = 1:tamSeqCom
        % Sai do laço ao clicar no botão Parar
        if seqEmExecucao == false
            break;
        end
        
        if (iscellstr(comandos))
            comandoCorrente = comandos{j};
        else
            comandoCorrente = comandos(j,:);
        end
        tamComandoCorrente = length(comandoCorrente);
        
        % Hints: contents = cellstr(get(hObject,'String')) returns listSequenciaComandos contents as cell array
        %        contents{get(hObject,'Value')} returns selected item from
        %        listSequenciaComandos
        
        set(handles.listSequenciaComandos, 'Value', j);
        if tamComandoCorrente > 0 && comandoCorrente(1) == '[' && comandoCorrente(tamComandoCorrente) == ']'
            if comandoCorrente(2) == 'G'
                idxAux = 3;
            else
                idxAux = 4;          
            end
            comando = comandoCorrente(2:idxAux);

            switch(comando)
                case 'GA'
                    comandoAbrirGarra(hObject, handles);
                case 'GF'
                    comandoFecharGarra(hObject, handles);
                case 'CTZ'
                    junta = comandoCorrente(5:6);
                    comandoCTZ(junta, hObject, handles);
                case 'JST'
                    valor = [0 0 0 0 0 0];
                    for i = 1:6
                        iServo = 5*i;
                        strValor = comandoCorrente(iServo+1:iServo+4);
                        valor(i) = str2double(strValor);
                    end
                    juntas = ['J0'; 'J1'; 'J2'; 'J3'; 'J4'; 'GR'];
                    for i = 1:6
                        campoEditAlvo = ['edt' juntas(i,:) 'Alvo'];
                        set(handles.(campoEditAlvo),'String',num2str(valor(i)));
                        drawnow;
                    end
                    comandoPosicionarTodasJuntas(hObject, handles);
                case 'RPS'
                    comandoRepouso(hObject, handles);
                case {'VEL','ACL'}
                    junta = comandoCorrente(5:6);
                    %--- comando = VEL, ACL; junta = J0, J1,...,J4, GR;
                    %    valorASetar >= 0 seta valor; valorASetar = -1 apenas puxa valor da placa
                    %    de controle
                    if length(comandoCorrente) == 11
                        valorASetar = str2double(comandoCorrente(7:10));
                    else
                        valorASetar = -1; % Apenas obter valor de velocidade ou aceleração
                    end
                    comandoVELOuACL(comando, junta, valorASetar, hObject, handles);

            % Comando delay (não existe na placa de controle) [DLYXXXX], XXXX =
            % tempo em milissegundos. [DLY] pausa até que o usuário pressione
            % qualquer tecla
            case 'DLY'               
                if tamComandoCorrente == 9
                    tempoDelay = str2double(comandoCorrente(5:8))/1000;
                    if tempoDelay > 0
                        pause(tempoDelay);
                    else
                        pause;
                    end
                elseif tamComandoCorrente == 5
                    pause;
                end
            end
        elseif tamComandoCorrente > 0 %% A ser encarado como comentário
            disp(['Comentário: ' comandoCorrente]);
        end
    end
end



% --- Executes on button press in botaoPararSeq.
function botaoPararSeq_Callback(hObject, eventdata, handles)
% hObject    handle to botaoPararSeq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global seqEmExecucao;
seqEmExecucao = false;
guidata(hObject, handles);


% --- Executes on button press in botaoRemoverComando.
function botaoRemoverComando_Callback(hObject, eventdata, handles)
% hObject    handle to botaoRemoverComando (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listSequenciaComandos contents as cell array
%        contents{get(hObject,'Value')} returns selected item from
%        listSequenciaComandos

comandos = cellstr(get(handles.listSequenciaComandos,'String'));
tam = size(comandos);
tamSeqCom = tam(1);
if tamSeqCom > 0
    index_selected = get(handles.listSequenciaComandos,'Value');
    novosComandos = comandos;
       
    if tamSeqCom > 1
        novosComandos(index_selected) = [];
    else
        novosComandos = '';
    end
    if index_selected - 1 > 0
        index_selected = index_selected - 1;
    end
    if tamSeqCom > 0
        tamSeqCom = tamSeqCom - 1;
    end
    
    set(handles.listSequenciaComandos,'String', novosComandos, 'Value', min(index_selected, tamSeqCom));
    drawnow;
else
    disp('Sequência Vazia');
end



% --- Executes on button press in botaoEditarComando.
function botaoEditarComando_Callback(hObject, eventdata, handles)
% hObject    handle to botaoEditarComando (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listSequenciaComandos contents as cell array
%        contents{get(hObject,'Value')} returns selected item from
%        listSequenciaComandos

comandos = cellstr(get(handles.listSequenciaComandos,'String'));
tam = size(comandos);
tamSeqCom = tam(1);
if tamSeqCom > 0
    index_selected = get(handles.listSequenciaComandos,'Value');
    item_selected = comandos{index_selected};
    
    prompt = {'Comando a ser editado:'};
    dlg_title = 'Editar Comando';
    num_lines = 1;
    def = { item_selected };
    comando = inputdlg(prompt,dlg_title,num_lines,def);
    if ~isempty(comando)
        if tamSeqCom > 1
            comandos(index_selected) = comando;
        else
            comandos = comando;
        end
        set(handles.listSequenciaComandos,'String',comandos);
    end
else
    disp('Sequência Vazia');
end



% --- Executes on button press in botaoComandoUp.
function botaoComandoUp_Callback(hObject, eventdata, handles)
% hObject    handle to botaoComandoUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
comandos = cellstr(get(handles.listSequenciaComandos,'String'));
tam = size(comandos);
tamSeqCom = tam(1);
index_selected = get(handles.listSequenciaComandos,'Value');

if tamSeqCom > 1 && index_selected > 1
    
    comandoTemp = comandos{index_selected};
    comandos{index_selected} = comandos{index_selected - 1};
    comandos{index_selected - 1} = comandoTemp;    
    index_selected = index_selected - 1;
    set(handles.listSequenciaComandos,'String',comandos, 'Value', index_selected);
    
else
    disp('Sequência vazia ou com apenas 1 item, ou primeiro item selecionado.');
end



% --- Executes on button press in botaoComandoDown.
function botaoComandoDown_Callback(hObject, eventdata, handles)
% hObject    handle to botaoComandoDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
comandos = cellstr(get(handles.listSequenciaComandos,'String'));
tam = size(comandos);
tamSeqCom = tam(1);
index_selected = get(handles.listSequenciaComandos,'Value');

if tamSeqCom > 1 && index_selected < tamSeqCom
    comandoTemp = comandos{index_selected};
    comandos{index_selected} = comandos{index_selected + 1};
    comandos{index_selected + 1} = comandoTemp;
    index_selected = index_selected + 1;
    set(handles.listSequenciaComandos,'String',comandos, 'Value', index_selected);
else
    disp('Sequência vazia ou com apenas 1 item, ou último item selecionado.');
end



% --------------------------------------------------------------------
function conmenuExecutarComSel_Callback(hObject, eventdata, handles)
% hObject    handle to conmenuExecutarComSel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
comandos = cellstr(get(handles.listSequenciaComandos,'String'));
[tamComandos,~] = size(comandos);
listaComandosHabilitada = get(handles.listSequenciaComandos,'Enable');
index_selected = get(handles.listSequenciaComandos,'Value');
if strcmp(listaComandosHabilitada, 'on') && tamComandos > 0 && ~isempty(index_selected)
    comandoCorrente = comandos{index_selected};
    tamComandoCorrente = length(comandoCorrente);
    if tamComandoCorrente > 0 && comandoCorrente(1) == '[' && comandoCorrente(tamComandoCorrente) == ']'
        if comandoCorrente(2) == 'G'
            idxAux = 3;
        else
            idxAux = 4;
        end
        comando = comandoCorrente(2:idxAux);

        switch(comando)
            case 'GA'
                comandoAbrirGarra(hObject, handles);
            case 'GF'
                comandoFecharGarra(hObject, handles);
            case 'CTZ'
                junta = comandoCorrente(5:6);
                comandoCTZ(junta, hObject, handles);
            case 'JST'
                valor = [0 0 0 0 0 0];
                for i = 1:6
                    iServo = 5*i;
                    strValor = comandoCorrente(iServo+1:iServo+4);
                    valor(i) = str2double(strValor);
                end
                juntas = ['J0'; 'J1'; 'J2'; 'J3'; 'J4'; 'GR'];
                for i = 1:6
                    campoEditAlvo = ['edt' juntas(i,:) 'Alvo'];
                    set(handles.(campoEditAlvo),'String',num2str(valor(i)));
                    drawnow;
                end
                comandoPosicionarTodasJuntas(hObject, handles);
            case 'RPS'
                comandoRepouso(hObject, handles);
            case {'VEL','ACL'}
                junta = comandoCorrente(5:6);
                %--- comando = VEL, ACL; junta = J0, J1,...,J4, GR;
                %    valorASetar >= 0 seta valor; valorASetar = -1 apenas puxa valor da placa
                %    de controle
                if length(comandoCorrente) == 11
                    valorASetar = str2double(comandoCorrente(7:10));
                else
                    valorASetar = -1; % Apenas obter valor de velocidade ou aceleração
                end
                comandoVELOuACL(comando, junta, valorASetar, hObject, handles);

            % Comando delay (não existe na placa de controle) [DLYXXXX], XXXX =
            % tempo em milissegundos. [DLY] pausa até que o usuário pressione
            % qualquer tecla
            case 'DLY' 
                if tamComandoCorrente == 9
                    tempoDelay = str2double(comandoCorrente(5:8))/1000;
                    if tempoDelay > 0
                        pause(tempoDelay);
                    else
                        pause;
                    end
                elseif tamComandoCorrente == 5
                    pause;
                end
        end
    elseif tamComandoCorrente > 0 %% A ser encarado como comentário
        disp(['Comentário: ' comandoCorrente]);
    end
end


%-------------------------------------------------------
% Funções de Obtenção de Resposta/Feedback dos Comandos
%-------------------------------------------------------


%---
function ObterFeedBackMultiJuntas(hObject, handles)

juntas = ['J0'; 'J1'; 'J2'; 'J3'; 'J4'; 'GR'];

cmdGetMovingState = hex2dec('93');

fwrite(handles.serConn, cmdGetMovingState);
movingState = fread(handles.serConn,1);

while(movingState == 1)
    for i = 1:6
        canal = hex2dec(dec2hex(i-1));
        cmdGetPosition = [ hex2dec('90') canal ];

        fwrite(handles.serConn, cmdGetPosition);

        bytesPosicao = fread(handles.serConn,2);

        if(~isempty(bytesPosicao))
            posicao = (bytesPosicao(1) + 256*bytesPosicao(2))/4;
            fprintf('%s: %07.2f  ', juntas(i,:), posicao)
            campoEditAtual = ['edt' juntas(i,:) 'Atual'];
            set(handles.(campoEditAtual),'String',num2str(posicao));
            drawnow;
        end
    end
    fprintf('\n')
    
    fwrite(handles.serConn, cmdGetMovingState);
    movingState = fread(handles.serConn,1);
end

for i = 1:6
    canal = hex2dec(dec2hex(i-1));
    cmdGetPosition = [ hex2dec('90') canal ];

    fwrite(handles.serConn, cmdGetPosition);

    bytesPosicao = fread(handles.serConn,2);

    if(~isempty(bytesPosicao))
        posicao = (bytesPosicao(1) + 256*bytesPosicao(2))/4;
        fprintf('%s: %07.2f  ', juntas(i,:), posicao)
        campoEditAtual = ['edt' juntas(i,:) 'Atual'];
        set(handles.(campoEditAtual),'String',num2str(posicao));
        campoEditAlvo = ['edt' juntas(i,:) 'Alvo'];
        set(handles.(campoEditAlvo),'String',num2str(posicao));
        drawnow;
    end
end
fprintf('\n')

guidata(hObject, handles);


%---
function ObterFeedBackJunta(junta, hObject, handles)
juntas = ['J0'; 'J1'; 'J2'; 'J3'; 'J4'; 'GR'];
switch(junta)
    case {'J0','J1','J2','J3','J4'}
        jnt = str2double(junta(2))+1;
        canalMM = hex2dec(dec2hex(jnt-1));
    case 'GR'
        jnt = 6;
        canalMM = hex2dec('05');
end
cmdGetMovingState = hex2dec('93');

fwrite(handles.serConn, cmdGetMovingState);
movingState = fread(handles.serConn,1);

while(movingState == 1)
    cmdGetPosition = [ hex2dec('90') canalMM ];
    fwrite(handles.serConn, cmdGetPosition);
    bytesPosicao = fread(handles.serConn,2);
    if(~isempty(bytesPosicao))
        posicao = (bytesPosicao(1) + 256*bytesPosicao(2))/4;
        fprintf('%s: %07.2f  ', juntas(jnt,:), posicao)
        campoEditAtual = ['edt' juntas(jnt,:) 'Atual'];
        set(handles.(campoEditAtual),'String',num2str(posicao));
        drawnow;
    end
    fprintf('\n')
    fwrite(handles.serConn, cmdGetMovingState);
    movingState = fread(handles.serConn,1);
end

cmdGetPosition = [ hex2dec('90') canalMM ];
fwrite(handles.serConn, cmdGetPosition);
bytesPosicao = fread(handles.serConn,2);
if(~isempty(bytesPosicao))
    posicao = (bytesPosicao(1) + 256*bytesPosicao(2))/4;
    fprintf('%s: %07.2f  ', juntas(jnt,:), posicao)
    campoEditAtual = ['edt' juntas(jnt,:) 'Atual'];
    set(handles.(campoEditAtual),'String',num2str(posicao));
    campoEditAlvo = ['edt' juntas(jnt,:) 'Alvo'];
    set(handles.(campoEditAlvo),'String',num2str(posicao));
    drawnow;
end
fprintf('\n')

guidata(hObject, handles);



%----------
% Comandos
%----------

%---
function comandoAbrirGarra(hObject, handles)
tabelaPosLimitesData = get(handles.tabelaPosLimites,'Data');
alvo = tabelaPosLimitesData(6,1);
%alvo
set(handles.edtGRAlvo, 'String',num2str(alvo));
drawnow;
%atual
comandoPosicionarJunta('GR', alvo, hObject, handles);


%---
function comandoFecharGarra(hObject, handles)
tabelaPosLimitesData = get(handles.tabelaPosLimites,'Data');
alvo = tabelaPosLimitesData(6,2);
%alvo
set(handles.edtGRAlvo, 'String',num2str(alvo));
drawnow;
%atual
comandoPosicionarJunta('GR', alvo, hObject, handles);


%---
function comandoGarraSemiAberta(hObject, handles)
comandoCTZ('GR', hObject, handles);


%--- junta = J0, J1, J2, J3, J4 ou GR
function comandoCTZ(junta, hObject, handles)
switch(junta)
    case {'J0','J1','J2','J3','J4'}
        canal = str2double(junta(2));
        canalMM = hex2dec(dec2hex(canal));
    case 'GR'
        canal = 5;
        canalMM = hex2dec('05');
end
tabelaPosLimitesData = get(handles.tabelaPosLimites,'Data');
alvo = tabelaPosLimitesData(canal+1,3);
%alvo
campoEditAlvo = ['edt' junta 'Alvo'];
set(handles.(campoEditAlvo),'String',num2str(alvo));
drawnow;
%atual
alvoMM = hex2dec(dec2hex(alvo * 4));
valorL = bitand(alvoMM, hex2dec('7F'));
valorH = bitand(bitshift(alvoMM,-7),hex2dec('7F')); % -7 para deslocar 7 bits para a direita

cmdSetTarget = [ hex2dec('84') canalMM valorL valorH ];
fwrite(handles.serConn, cmdSetTarget);

ObterFeedBackJunta(junta, hObject, handles);


%---
function comandoRepouso(hObject, handles)
juntas = ['J0'; 'J1'; 'J2'; 'J3'; 'J4'; 'GR'];
tabelaPosLimitesData = get(handles.tabelaPosLimites,'Data');
for i=1:6
    alvo = tabelaPosLimitesData(i,4);
    campoEditAlvo = ['edt' juntas(i,:) 'Alvo'];
    set(handles.(campoEditAlvo),'String',num2str(alvo));
    drawnow;
end
%Atual
comandoPosicionarTodasJuntas(hObject, handles);


%---
function comandoDesligarServos(hObject, handles)
juntas = ['J0'; 'J1'; 'J2'; 'J3'; 'J4'; 'GR'];
for i=1:6
    alvo = 0;
    campoEditAlvo = ['edt' juntas(i,:) 'Alvo'];
    set(handles.(campoEditAlvo),'String',num2str(alvo));
    drawnow;
end
comandoPosicionarTodasJuntas(hObject, handles);




%---
function comandoObterPosicoesAtuais(hObject, handles)
juntas = ['J0'; 'J1'; 'J2'; 'J3'; 'J4'; 'GR'];

for i = 1:6
    canal = hex2dec(dec2hex(i-1));
    cmdGetPosition = [ hex2dec('90') canal ];

    fwrite(handles.serConn, cmdGetPosition);

    bytesPosicao = fread(handles.serConn,2);

    if(~isempty(bytesPosicao))
        posicao = (bytesPosicao(1) + 256*bytesPosicao(2))/4;
        fprintf('%s: %07.2f  ', juntas(i,:), posicao)
        campoEditAlvo = ['edt' juntas(i,:) 'Alvo'];
        set(handles.(campoEditAlvo),'String',num2str(posicao));
        campoEditAtual = ['edt' juntas(i,:) 'Atual'];
        set(handles.(campoEditAtual),'String',num2str(posicao));
        drawnow;
    end
end
fprintf('\n');


%---
function comandoPosicionarTodasJuntas(hObject, handles)
juntas = ['J0'; 'J1'; 'J2'; 'J3'; 'J4'; 'GR'];

arrayBytesAlvos = repmat(hex2dec('00'), 1, 12);

enviarComVelAcl = strcmp(get(hObject,'Tag'),'botaoMoverComVelAcl');

% Envia velocidades e acelerações e monta o comando JST
for i = 1:6
    if enviarComVelAcl
        campoVEL = ['edt' juntas(i,:) 'Vel'];
        campoACL = ['edt' juntas(i,:) 'Acl'];
        velocidade = str2double(get(handles.(campoVEL),'String'));
        aceleracao = str2double(get(handles.(campoACL),'String'));
        comandoVELOuACL('VEL', juntas(i,:), velocidade, hObject, handles);
        comandoVELOuACL('ACL', juntas(i,:), aceleracao, hObject, handles);
    end
    
    alvo = str2double(get(handles.(['edt' juntas(i,:) 'Alvo']),'String'));
    alvo = hex2dec(dec2hex(4*alvo));
    
    valorL = bitand(alvo, hex2dec('7F'));
    valorH = bitand(bitshift(alvo,-7),hex2dec('7F')); % -7 para deslocar 7 bits para a direita
    
    arrayBytesAlvos(2*i-1) = valorL;
    arrayBytesAlvos(2*i) = valorH;
end

cmdSetMultipleTargets = [hex2dec('9F') hex2dec('06') hex2dec('00') arrayBytesAlvos];
fwrite(handles.serConn, cmdSetMultipleTargets);

ObterFeedBackMultiJuntas(hObject, handles);


%--- Junta = J0, J1,...,J4, GR    ou  A, B, C, D, E, G; alvo: valor da
%posição em microssegundos
function comandoPosicionarJunta(junta, alvo, hObject, handles)
juntas = ['J0'; 'J1'; 'J2'; 'J3'; 'J4'; 'GR'];
juntasIdJST = 'ABCDEG';
idxJunta = 0;
for i = 1:6
   if strcmp(junta, juntas(i,:)) || strcmp(junta, juntasIdJST(i))
       idxJunta = i;
       canalMM = hex2dec(dec2hex(i-1));
       break;
   end
end

enviarComVelAcl = strcmp(get(hObject,'Tag'),'botaoMoverComVelAcl');

if enviarComVelAcl
    % Envia velocidades e acelerações
    campoVEL = ['edt' juntas(idxJunta,:) 'Vel'];
    campoACL = ['edt' juntas(idxJunta,:) 'Acl'];
    velocidade = str2double(get(handles.(campoVEL),'String'));
    aceleracao = str2double(get(handles.(campoACL),'String'));
    comandoVELOuACL('VEL', juntas(idxJunta,:), velocidade, hObject, handles);
    comandoVELOuACL('ACL', juntas(idxJunta,:), aceleracao, hObject, handles);
end
% monta o set target
alvoMM = hex2dec(dec2hex(alvo * 4));
valorL = bitand(alvoMM, hex2dec('7F'));
valorH = bitand(bitshift(alvoMM,-7),hex2dec('7F')); % -7 para deslocar 7 bits para a direita

cmdSetTarget = [ hex2dec('84') canalMM valorL valorH ];

fwrite(handles.serConn, cmdSetTarget);
ObterFeedBackMultiJuntas(hObject, handles);



%--- comando = VEL, ACL; junta = J0, J1,...,J4, GR;
%    valorASetar >= 0 seta valor; valorASetar = -1 apenas puxa valor da placa
%    de controle
function comandoVELOuACL(comando, junta, valorASetar, hObject, handles)

if valorASetar >= 0
    valor = hex2dec(dec2hex(valorASetar));
    switch(comando)
        case 'VEL'
            cmdMM = hex2dec('87'); % Set Speed
        case 'ACL'
            cmdMM = hex2dec('89'); % Set Acceleration
    end

    switch(junta)
        case {'J0','J1','J2','J3','J4'}
            canalMM = str2double(junta(2));
            canalMM = hex2dec(dec2hex(canalMM));
        case 'GR'
            canalMM = hex2dec('05');
    end
    
    valorL = bitand(valor, hex2dec('7F'));
    valorH = bitand(bitshift(valor,-7),hex2dec('7F')); % -7 para deslocar 7 bits para a direita
    
    fwrite(handles.serConn,[cmdMM canalMM valorL valorH]);
end
