function varargout = tela_controle_mm_cinematica_dir_inv(varargin)
% TELA_CONTROLE_MM_CINEMATICA_DIR_INV M-file for tela_controle_mm_cinematica_dir_inv.fig
%      TELA_CONTROLE_MM_CINEMATICA_DIR_INV, by itself, creates a new TELA_CONTROLE_MM_CINEMATICA_DIR_INV or raises the existing
%      singleton*.
%
%      H = TELA_CONTROLE_MM_CINEMATICA_DIR_INV returns the handle to a new TELA_CONTROLE_MM_CINEMATICA_DIR_INV or the handle to
%      the existing singleton*.
%
%      TELA_CONTROLE_MM_CINEMATICA_DIR_INV('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TELA_CONTROLE_MM_CINEMATICA_DIR_INV.M with the given input arguments.
%
%      TELA_CONTROLE_MM_CINEMATICA_DIR_INV('Property','Value',...) creates a new TELA_CONTROLE_MM_CINEMATICA_DIR_INV or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before tela_controle_mm_cinematica_dir_inv_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to tela_controle_mm_cinematica_dir_inv_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help tela_controle_mm_cinematica_dir_inv

% Last Modified by GUIDE v2.5 23-Aug-2015 02:50:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @tela_controle_mm_cinematica_dir_inv_OpeningFcn, ...
                   'gui_OutputFcn',  @tela_controle_mm_cinematica_dir_inv_OutputFcn, ...
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


% --- Executes just before tela_controle_mm_cinematica_dir_inv is made visible.
function tela_controle_mm_cinematica_dir_inv_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to tela_controle_mm_cinematica_dir_inv (see VARARGIN)

% Choose default command line output for tela_controle_mm_cinematica_dir_inv
handles.output = hObject;
clc

tabelaPosLimitesData = [[2432 480 1405 480];[2256 768 1798 2256];[2208 800 2208 959];[2480 528 1251 1836];[2432 512 1472 1472];[2000 416 (2000+416)/2 2000]];
set(handles.tabelaPosLimites,'Data',tabelaPosLimitesData);
% tabelaPosLimGrausData = [[100 -90 0 0 0]; [40 -90 0 0 0]; [0 -133 0 0 0]; [74 -126 0 0 1]; [90 -90 0 0 0]; [180 0 0 0 0]];
tabelaPosLimGrausData = [[100 -90 0 0 0]; [130 0 0 0 0]; [0 -133 0 0 0]; [164 -36 0 0 1]; [90 -90 0 0 0]; [180 0 0 0 0]];


global juntas
juntas = ['J0'; 'J1'; 'J2'; 'J3'; 'J4'; 'GR'];

coeffAng = [0 0 0 0 0 0];
offsetAng = [0 0 0 0 0 0];

tempoPulsoMax = tabelaPosLimitesData(:,1);
tempoPulsoMin = tabelaPosLimitesData(:,2);
tempoPulsoNeutro = tabelaPosLimitesData(:,3);
tempoPulsoRepouso = tabelaPosLimitesData(:,4);
angMax = tabelaPosLimGrausData(:,1);
angMin = tabelaPosLimGrausData(:,2);
propInv = tabelaPosLimGrausData(:,5);
incrementosAng = [0 0 0 0 0 0];
qtdPosicoesTmpPulso = [0 0 0 0 0 0];
velTmpPulso = [64 32 32 32 128 100];
aclTmpPulso = [8 4 8 8 32 0];
velGrausPorSeg = [0 0 0 0 0 0];
aclGrausPorSegQuad = [0 0 0 0 0 0];
for i=1:6
    if(propInv(i) == 1)
        coeffAng(i) = (angMin(i)-angMax(i))/(tempoPulsoMax(i) - tempoPulsoMin(i));
        offsetAng(i) = angMin(i) - tempoPulsoMax(i) * coeffAng(i);
    else
        coeffAng(i) = (angMax(i)-angMin(i))/(tempoPulsoMax(i) - tempoPulsoMin(i));
        offsetAng(i) = angMax(i) - tempoPulsoMax(i) * coeffAng(i);
    end
    anguloNeutro = coeffAng(i) * tempoPulsoNeutro(i) + offsetAng(i);
    tabelaPosLimGrausData(i,3) = anguloNeutro;
    anguloRepouso = coeffAng(i) * tempoPulsoRepouso(i) + offsetAng(i);
    tabelaPosLimGrausData(i,4) = anguloRepouso;
    
    qtdPosicoesTmpPulso(i) = (tempoPulsoMax(i) - tempoPulsoMin(i)) / 0.25;
    
    incrementosAng(i) = (angMax(i) - angMin(i))/qtdPosicoesTmpPulso(i);
    
    velGrausPorSeg(i) = velTmpPulso(i) * incrementosAng(i) / (10 * 10^(-3)); % 0.25us/10ms
    
    aclGrausPorSegQuad(i) = aclTmpPulso(i) * incrementosAng(i) / (10*10^(-3)) / (80*10^(-3)); %(0.25us)/(10ms)/(80ms)
end

qtdPosicoesTmpPulso

incrementosAng

velGrausPorSeg

aclGrausPorSegQuad

set(handles.tabelaPosLimGraus,'Data',tabelaPosLimGrausData);

handles.coeffAng = coeffAng;
handles.offsetAng = offsetAng;
handles.incrementosAng = incrementosAng;
handles.tempoPulsoMax = tempoPulsoMax;
handles.tempoPulsoMin = tempoPulsoMin;
handles.angMax = angMax;
handles.angMin = angMin;

handles.velocidadesMax = [128 128 128 92 128 100];
handles.aceleracoesMax = [8 4 8 8 32 100];

global seqEmExecucao
seqEmExecucao = false;

global arquivoSeqComandos;
arquivoSeqComandos = '';
handles.titleSeqComandos = get(handles.uipSeqComandos, 'Title');
global filenameSeqComandos;
filenameSeqComandos = '';


uipUnidadePos_SelectionChangeFcn(handles.uipUnidadePos, eventdata, handles);

positionFig = get(handles.figure1,'Position');
positionFig(3) = 112;
set(handles.figure1,'Position',positionFig);

HabilitarComponentesConn('Off', hObject, handles);

% Update handles structure
guidata(hObject, handles);
%clear all;


% UIWAIT makes tela_controle_mm_cinematica_dir_inv wait for user response (see UIRESUME)
% uiwait(handles.figure1);



% --- Outputs from this function are returned to the command line.
function varargout = tela_controle_mm_cinematica_dir_inv_OutputFcn(hObject, eventdata, handles) 
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
    converteVelTmpPulsoParaGrausPorSeg_Callback(handles.(['edt' juntas(i,:) 'Vel']), eventdata, handles);
    converteAclTmpPulsoParaGrausPorSegQuad_Callback(handles.(['edt' juntas(i,:) 'Acl']), eventdata, handles);
end

comandoObterPosicoesAtuais(hObject, handles);



%--- estadoHab = 'On' ou 'Off'
function HabilitarComponentes(estadoHab, hObject, handles)
set(handles.botaoFecharPortaSerial, 'Enable',estadoHab);
if(strcmp(estadoHab,'Off'))
    set(handles.botaoAbrirGarra, 'Enable',estadoHab);
    set(handles.botaoFecharGarra, 'Enable',estadoHab);
    set(handles.botaoGarraSemiaberta, 'Enable',estadoHab);
    set(handles.botaoGirarGarraMais90, 'Enable',estadoHab);
    set(handles.botaoGirarGarraMenos90, 'Enable',estadoHab);
    set(handles.botaoGarraPosNeutra, 'Enable',estadoHab);
    set(handles.botaoPosNeutraCTZ, 'Enable',estadoHab);
    set(handles.botaoPosNeutraJST, 'Enable',estadoHab);
end
set(handles.botaoPosRepouso, 'Enable',estadoHab);
set(handles.botaoDesligaServos, 'Enable',estadoHab);
juntas = ['J0';'J1';'J2';'J3';'J4';'GR'];
for i = 1:6
    set(handles.(['edt' juntas(i,:) 'Alvo']), 'Enable', estadoHab);
    set(handles.(['edt' juntas(i,:) 'Vel']), 'Enable', estadoHab);
    set(handles.(['edt' juntas(i,:) 'Acl']), 'Enable', estadoHab);
    set(handles.(['edt' juntas(i,:) 'AlvoGraus']), 'Enable', estadoHab);
    set(handles.(['edt' juntas(i,:) 'VelGrausPorSeg']), 'Enable', estadoHab);
    set(handles.(['edt' juntas(i,:) 'AclGrausPorSegQuad']), 'Enable', estadoHab);
end
set(handles.botaoObterPosicoes, 'Enable', estadoHab);
set(handles.botaoMover, 'Enable', estadoHab);
set(handles.botaoMoverComVelAcl, 'Enable', estadoHab);
set(handles.tabelaPosLimites, 'Enable', estadoHab);
set(handles.tabelaPosLimGraus, 'Enable', estadoHab);
set(handles.listSequenciaComandos, 'Enable', estadoHab);
set(handles.botaoNovaSequencia, 'Enable', estadoHab);
set(handles.botaoAdicionarComando, 'Enable', estadoHab);
set(handles.botaoAdicionarPosCorrente, 'Enable', estadoHab);
set(handles.chkComVelocidades, 'Enable', estadoHab);
set(handles.chkComAceleracoes, 'Enable', estadoHab);
set(handles.botaoEditarComando, 'Enable', estadoHab);
set(handles.botaoRemoverComando, 'Enable', estadoHab);
set(handles.botaoCarregarSeq, 'Enable', estadoHab);
set(handles.botaoSalvarSeq, 'Enable', estadoHab);
set(handles.botaoExecutarSeq, 'Enable', estadoHab);
set(handles.botaoContinuar, 'Enable', estadoHab);
set(handles.botaoExecutarLoop, 'Enable', estadoHab);
set(handles.botaoContinuarLoop, 'Enable', estadoHab);
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


%--- Habilita ou desabilita componentes de acordo com os servos estarem
%ligados ou desligados
function HabilitarComponentesComServosLigados(hObject, handles)
global juntas;
estadoHabBool = true;
i = 1;
while(i <= 6 && estadoHabBool)
    campoPosAtual = ['edt' juntas(i,:) 'Atual'];
    posAtual = str2double(get(handles.(campoPosAtual), 'String'));
    estadoHabBool = estadoHabBool && ( posAtual ~= 0 );
    i = i+1;
end

if(estadoHabBool)
    estadoHab = 'On';
else
    estadoHab = 'Off';
end

set(handles.botaoAbrirGarra, 'Enable', estadoHab);
set(handles.botaoFecharGarra, 'Enable', estadoHab);
set(handles.botaoGarraSemiaberta, 'Enable', estadoHab);
set(handles.botaoGirarGarraMais90, 'Enable', estadoHab);
set(handles.botaoGirarGarraMenos90, 'Enable', estadoHab);
set(handles.botaoGarraPosNeutra, 'Enable', estadoHab);
set(handles.botaoPosNeutraCTZ, 'Enable', estadoHab);
set(handles.botaoPosNeutraJST, 'Enable', estadoHab);


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
%Alimenta o popup com as portas seriais dispon�veis
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
HabilitarComponentesConn('Off', hObject, handles);
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
HabilitarComponentesComServosLigados(hObject, handles);


% --- Executes on button press in botaoDesligaServos.
function botaoDesligaServos_Callback(hObject, eventdata, handles)
% hObject    handle to botaoDesligaServos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global juntas;
servosLigados = true;
i = 1;
while(i <= 6 && servosLigados)
    campoPosAtual = ['edt' juntas(i,:) 'Atual'];
    posAtual = str2double(get(handles.(campoPosAtual), 'String'));
    servosLigados = servosLigados && ( posAtual ~= 0 );
    i = i+1;
end

if (servosLigados)
    comandoRepouso(hObject, handles);
end
%pause(10)
comandoDesligarServos(hObject, handles);
HabilitarComponentesComServosLigados(hObject, handles);

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
HabilitarComponentesComServosLigados(hObject, handles);


% --- Executes on button press in botaoMoverComVelAcl.
function botaoMoverComVelAcl_Callback(hObject, eventdata, handles)
% hObject    handle to botaoMoverComVelAcl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
comandoPosicionarTodasJuntas(hObject, handles);
HabilitarComponentesComServosLigados(hObject, handles);


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
if(strcmp(get(hObject,'String'),'Configura��es...'))
    positionFig = get(handles.figure1,'Position');
    positionFig(3) = 204;
    set(handles.figure1,'Position',positionFig);
    set(hObject,'String','Fechar Config.');
else
    positionFig = get(handles.figure1,'Position');
    positionFig(3) = 112;
    set(handles.figure1,'Position',positionFig);
    set(hObject,'String','Configura��es...');
end


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


% --- Executes when entered data in editable cell(s) in tabelaPosLimites.
function tabelaPosLimites_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to tabelaPosLimites (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
idxJunta = eventdata.Indices(1);
coluna = eventdata.Indices(2);
switch(coluna)
    case 1
        handles.tempoPulsoMin(idxJunta) = eventdata.NewData;
    case 2
        handles.tempoPulsoMax(idxJunta) = eventdata.NewData;
end





% --- Executes when entered data in editable cell(s) in tabelaPosLimGraus.
function tabelaPosLimGraus_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to tabelaPosLimGraus (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
idxJunta = eventdata.Indices(1);
coluna = eventdata.Indices(2);
switch(coluna)
    case 1
        handles.angMin(idxJunta) = eventdata.NewData;
    case 2
        handles.angMax(idxJunta) = eventdata.NewData;
end



% --- Executes during object creation, after setting all properties.
function edtJ0AlvoGraus_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtJ0AlvoGraus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtJ1AlvoGraus_Callback(hObject, eventdata, handles)
% hObject    handle to edtJ1AlvoGraus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtJ1AlvoGraus as text
%        str2double(get(hObject,'String')) returns contents of edtJ1AlvoGraus as a double


% --- Executes during object creation, after setting all properties.
function edtJ1AlvoGraus_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtJ1AlvoGraus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtJ2AlvoGraus_Callback(hObject, eventdata, handles)
% hObject    handle to edtJ2AlvoGraus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtJ2AlvoGraus as text
%        str2double(get(hObject,'String')) returns contents of edtJ2AlvoGraus as a double


% --- Executes during object creation, after setting all properties.
function edtJ2AlvoGraus_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtJ2AlvoGraus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtJ3AlvoGraus_Callback(hObject, eventdata, handles)
% hObject    handle to edtJ3AlvoGraus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtJ3AlvoGraus as text
%        str2double(get(hObject,'String')) returns contents of edtJ3AlvoGraus as a double


% --- Executes during object creation, after setting all properties.
function edtJ3AlvoGraus_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtJ3AlvoGraus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtJ4AlvoGraus_Callback(hObject, eventdata, handles)
% hObject    handle to edtJ4AlvoGraus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtJ4AlvoGraus as text
%        str2double(get(hObject,'String')) returns contents of edtJ4AlvoGraus as a double


% --- Executes during object creation, after setting all properties.
function edtJ4AlvoGraus_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtJ4AlvoGraus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtGRAlvoGraus_Callback(hObject, eventdata, handles)
% hObject    handle to edtGRAlvoGraus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtGRAlvoGraus as text
%        str2double(get(hObject,'String')) returns contents of edtGRAlvoGraus as a double


% --- Executes during object creation, after setting all properties.
function edtGRAlvoGraus_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtGRAlvoGraus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtJ0AtualGraus_Callback(hObject, eventdata, handles)
% hObject    handle to edtJ0AtualGraus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtJ0AtualGraus as text
%        str2double(get(hObject,'String')) returns contents of edtJ0AtualGraus as a double


% --- Executes during object creation, after setting all properties.
function edtJ0AtualGraus_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtJ0AtualGraus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtJ1AtualGraus_Callback(hObject, eventdata, handles)
% hObject    handle to edtJ1AtualGraus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtJ1AtualGraus as text
%        str2double(get(hObject,'String')) returns contents of edtJ1AtualGraus as a double


% --- Executes during object creation, after setting all properties.
function edtJ1AtualGraus_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtJ1AtualGraus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtJ2AtualGraus_Callback(hObject, eventdata, handles)
% hObject    handle to edtJ2AtualGraus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtJ2AtualGraus as text
%        str2double(get(hObject,'String')) returns contents of edtJ2AtualGraus as a double


% --- Executes during object creation, after setting all properties.
function edtJ2AtualGraus_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtJ2AtualGraus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtJ3AtualGraus_Callback(hObject, eventdata, handles)
% hObject    handle to edtJ3AtualGraus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtJ3AtualGraus as text
%        str2double(get(hObject,'String')) returns contents of edtJ3AtualGraus as a double


% --- Executes during object creation, after setting all properties.
function edtJ3AtualGraus_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtJ3AtualGraus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtJ4AtualGraus_Callback(hObject, eventdata, handles)
% hObject    handle to edtJ4AtualGraus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtJ4AtualGraus as text
%        str2double(get(hObject,'String')) returns contents of edtJ4AtualGraus as a double


% --- Executes during object creation, after setting all properties.
function edtJ4AtualGraus_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtJ4AtualGraus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtGRAtualGraus_Callback(hObject, eventdata, handles)
% hObject    handle to edtGRAtualGraus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtGRAtualGraus as text
%        str2double(get(hObject,'String')) returns contents of edtGRAtualGraus as a double


% --- Executes during object creation, after setting all properties.
function edtGRAtualGraus_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtGRAtualGraus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtJ0VelGrausPorSeg_Callback(hObject, eventdata, handles)
% hObject    handle to edtJ0VelGrausPorSeg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtJ0VelGrausPorSeg as text
%        str2double(get(hObject,'String')) returns contents of edtJ0VelGrausPorSeg as a double


% --- Executes during object creation, after setting all properties.
function edtJ0VelGrausPorSeg_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtJ0VelGrausPorSeg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtJ1VelGrausPorSeg_Callback(hObject, eventdata, handles)
% hObject    handle to edtJ1VelGrausPorSeg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtJ1VelGrausPorSeg as text
%        str2double(get(hObject,'String')) returns contents of edtJ1VelGrausPorSeg as a double


% --- Executes during object creation, after setting all properties.
function edtJ1VelGrausPorSeg_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtJ1VelGrausPorSeg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtJ2VelGrausPorSeg_Callback(hObject, eventdata, handles)
% hObject    handle to edtJ2VelGrausPorSeg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtJ2VelGrausPorSeg as text
%        str2double(get(hObject,'String')) returns contents of edtJ2VelGrausPorSeg as a double


% --- Executes during object creation, after setting all properties.
function edtJ2VelGrausPorSeg_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtJ2VelGrausPorSeg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtJ3VelGrausPorSeg_Callback(hObject, eventdata, handles)
% hObject    handle to edtJ3VelGrausPorSeg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtJ3VelGrausPorSeg as text
%        str2double(get(hObject,'String')) returns contents of edtJ3VelGrausPorSeg as a double


% --- Executes during object creation, after setting all properties.
function edtJ3VelGrausPorSeg_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtJ3VelGrausPorSeg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtJ4VelGrausPorSeg_Callback(hObject, eventdata, handles)
% hObject    handle to edtJ4VelGrausPorSeg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtJ4VelGrausPorSeg as text
%        str2double(get(hObject,'String')) returns contents of edtJ4VelGrausPorSeg as a double


% --- Executes during object creation, after setting all properties.
function edtJ4VelGrausPorSeg_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtJ4VelGrausPorSeg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtGRVelGrausPorSeg_Callback(hObject, eventdata, handles)
% hObject    handle to edtGRVelGrausPorSeg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtGRVelGrausPorSeg as text
%        str2double(get(hObject,'String')) returns contents of edtGRVelGrausPorSeg as a double


% --- Executes during object creation, after setting all properties.
function edtGRVelGrausPorSeg_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtGRVelGrausPorSeg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtJ0AclGrausPorSegQuad_Callback(hObject, eventdata, handles)
% hObject    handle to edtJ0AclGrausPorSegQuad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtJ0AclGrausPorSegQuad as text
%        str2double(get(hObject,'String')) returns contents of edtJ0AclGrausPorSegQuad as a double


% --- Executes during object creation, after setting all properties.
function edtJ0AclGrausPorSegQuad_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtJ0AclGrausPorSegQuad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtJ1AclGrausPorSegQuad_Callback(hObject, eventdata, handles)
% hObject    handle to edtJ1AclGrausPorSegQuad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtJ1AclGrausPorSegQuad as text
%        str2double(get(hObject,'String')) returns contents of edtJ1AclGrausPorSegQuad as a double


% --- Executes during object creation, after setting all properties.
function edtJ1AclGrausPorSegQuad_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtJ1AclGrausPorSegQuad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtJ2AclGrausPorSegQuad_Callback(hObject, eventdata, handles)
% hObject    handle to edtJ2AclGrausPorSegQuad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtJ2AclGrausPorSegQuad as text
%        str2double(get(hObject,'String')) returns contents of edtJ2AclGrausPorSegQuad as a double


% --- Executes during object creation, after setting all properties.
function edtJ2AclGrausPorSegQuad_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtJ2AclGrausPorSegQuad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtJ3AclGrausPorSegQuad_Callback(hObject, eventdata, handles)
% hObject    handle to edtJ3AclGrausPorSegQuad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtJ3AclGrausPorSegQuad as text
%        str2double(get(hObject,'String')) returns contents of edtJ3AclGrausPorSegQuad as a double


% --- Executes during object creation, after setting all properties.
function edtJ3AclGrausPorSegQuad_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtJ3AclGrausPorSegQuad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtJ4AclGrausPorSegQuad_Callback(hObject, eventdata, handles)
% hObject    handle to edtJ4AclGrausPorSegQuad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtJ4AclGrausPorSegQuad as text
%        str2double(get(hObject,'String')) returns contents of edtJ4AclGrausPorSegQuad as a double


% --- Executes during object creation, after setting all properties.
function edtJ4AclGrausPorSegQuad_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtJ4AclGrausPorSegQuad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtGRAclGrausPorSegQuad_Callback(hObject, eventdata, handles)
% hObject    handle to edtGRAclGrausPorSegQuad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtGRAclGrausPorSegQuad as text
%        str2double(get(hObject,'String')) returns contents of edtGRAclGrausPorSegQuad as a double


% --- Executes during object creation, after setting all properties.
function edtGRAclGrausPorSegQuad_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtGRAclGrausPorSegQuad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edtPosXAlvo_Callback(hObject, eventdata, handles)
% hObject    handle to edtPosXAlvo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtPosXAlvo as text
%        str2double(get(hObject,'String')) returns contents of edtPosXAlvo as a double


% --- Executes during object creation, after setting all properties.
function edtPosXAlvo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtPosXAlvo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtPosYAlvo_Callback(hObject, eventdata, handles)
% hObject    handle to edtPosYAlvo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtPosYAlvo as text
%        str2double(get(hObject,'String')) returns contents of edtPosYAlvo as a double


% --- Executes during object creation, after setting all properties.
function edtPosYAlvo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtPosYAlvo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtPosZAlvo_Callback(hObject, eventdata, handles)
% hObject    handle to edtPosZAlvo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtPosZAlvo as text
%        str2double(get(hObject,'String')) returns contents of edtPosZAlvo as a double


% --- Executes during object creation, after setting all properties.
function edtPosZAlvo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtPosZAlvo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtPosXAtual_Callback(hObject, eventdata, handles)
% hObject    handle to edtPosXAtual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtPosXAtual as text
%        str2double(get(hObject,'String')) returns contents of edtPosXAtual as a double


% --- Executes during object creation, after setting all properties.
function edtPosXAtual_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtPosXAtual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtPosYAtual_Callback(hObject, eventdata, handles)
% hObject    handle to edtPosYAtual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtPosYAtual as text
%        str2double(get(hObject,'String')) returns contents of edtPosYAtual as a double


% --- Executes during object creation, after setting all properties.
function edtPosYAtual_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtPosYAtual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtPosZAtual_Callback(hObject, eventdata, handles)
% hObject    handle to edtPosZAtual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtPosZAtual as text
%        str2double(get(hObject,'String')) returns contents of edtPosZAtual as a double


% --- Executes during object creation, after setting all properties.
function edtPosZAtual_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtPosZAtual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edtRxAlvo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtRxAlvo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edtRxAlvo_Callback(hObject, eventdata, handles)
% hObject    handle to edtRxAlvo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtRxAlvo as text
%        str2double(get(hObject,'String')) returns contents of edtRxAlvo as a double



function edtRyAlvo_Callback(hObject, eventdata, handles)
% hObject    handle to edtRyAlvo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtRyAlvo as text
%        str2double(get(hObject,'String')) returns contents of edtRyAlvo as a double


% --- Executes during object creation, after setting all properties.
function edtRyAlvo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtRyAlvo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtRzAlvo_Callback(hObject, eventdata, handles)
% hObject    handle to edtRzAlvo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtRzAlvo as text
%        str2double(get(hObject,'String')) returns contents of edtRzAlvo as a double


% --- Executes during object creation, after setting all properties.
function edtRzAlvo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtRzAlvo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtRxAtual_Callback(hObject, eventdata, handles)
% hObject    handle to edtRxAtual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtRxAtual as text
%        str2double(get(hObject,'String')) returns contents of edtRxAtual as a double


% --- Executes during object creation, after setting all properties.
function edtRxAtual_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtRxAtual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtRyAtual_Callback(hObject, eventdata, handles)
% hObject    handle to edtRyAtual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtRyAtual as text
%        str2double(get(hObject,'String')) returns contents of edtRyAtual as a double


% --- Executes during object creation, after setting all properties.
function edtRyAtual_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtRyAtual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtRzAtual_Callback(hObject, eventdata, handles)
% hObject    handle to edtRzAtual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtRzAtual as text
%        str2double(get(hObject,'String')) returns contents of edtRzAtual as a double


% --- Executes during object creation, after setting all properties.
function edtRzAtual_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtRzAtual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in botaoCalcularXYZAlvo.
function botaoCalcularXYZAlvo_Callback(hObject, eventdata, handles)
% hObject    handle to botaoCalcularXYZAlvo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global juntas
anguloAlvoJunta = [0 0 0 0 0 0];
for i=1:6
    campoAnguloAlvo = ['edt' juntas(i,:) 'AlvoGraus'];
    anguloAlvoJunta(i) = str2double(get(handles.(campoAnguloAlvo),'String'));
end

posAlvo = posicaoGarra(anguloAlvoJunta(1), anguloAlvoJunta(2), anguloAlvoJunta(3), anguloAlvoJunta(4), anguloAlvoJunta(5));

set(handles.edtPosXAlvo, 'String', num2str(posAlvo(1)));
set(handles.edtPosYAlvo, 'String', num2str(posAlvo(2)));
set(handles.edtPosZAlvo, 'String', num2str(posAlvo(3)));
set(handles.edtRxAlvo, 'String', num2str(posAlvo(4)));
set(handles.edtRyAlvo, 'String', num2str(posAlvo(5)));
set(handles.edtRzAlvo, 'String', num2str(posAlvo(6)));
drawnow;


% --- Executes on button press in botaoCalcularAngulosAlvo.
function botaoCalcularAngulosAlvo_Callback(hObject, eventdata, handles)
% hObject    handle to botaoCalcularAngulosAlvo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

x = str2double(get(handles.edtPosXAlvo, 'String'));
y = str2double(get(handles.edtPosYAlvo, 'String'));
z = str2double(get(handles.edtPosZAlvo, 'String'));
gamaGraus = str2double(get(handles.edtRxAlvo, 'String'));
betaGraus = str2double(get(handles.edtRyAlvo, 'String'));
alfaGraus = str2double(get(handles.edtRzAlvo, 'String'));

[angJunta, posAjustada] = angJuntas(x, y, z, gamaGraus, betaGraus, alfaGraus)

set(handles.edtPosXAlvo, 'String', num2str(posAjustada(1)));
set(handles.edtPosYAlvo, 'String', num2str(posAjustada(2)));
set(handles.edtPosZAlvo, 'String', num2str(posAjustada(3)));
set(handles.edtRxAlvo, 'String', num2str(posAjustada(4)));
set(handles.edtRyAlvo, 'String', num2str(posAjustada(5)));
set(handles.edtRzAlvo, 'String', num2str(posAjustada(6)));

global juntas

for i=1:5
    campoAlvoGraus = ['edt' juntas(i,:) 'AlvoGraus'];
    set(handles.(campoAlvoGraus), 'String', num2str(angJunta(i)));
    converteGrausParaTmpPulso_Callback(handles.(campoAlvoGraus), eventdata, handles)
end
%Refaz a cinem�tica direta para a corre��o final da posi��o
botaoCalcularXYZAlvo_Callback(handles.(campoAlvoGraus), eventdata, handles)


% --- estadoVisible = on ou off
function mostraCamposAngulares(estadoVisible, hObject, handles)
    juntas = ['J0'; 'J1'; 'J2'; 'J3'; 'J4'; 'GR'];
    for i=1:6
        set(handles.(['edt' juntas(i,:) 'AlvoGraus']), 'Visible', estadoVisible);
        set(handles.(['edt' juntas(i,:) 'AtualGraus']), 'Visible', estadoVisible);
        set(handles.(['edt' juntas(i,:) 'VelGrausPorSeg']), 'Visible', estadoVisible);
        set(handles.(['edt' juntas(i,:) 'AclGrausPorSegQuad']), 'Visible', estadoVisible);
    end

% --- Executes when selected object is changed in uipUnidadePos.
function uipUnidadePos_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipUnidadePos 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

switch(hObject)
    case handles.rdbLargPulsoMicroSeg
        mostraCamposAngulares('off', hObject, handles);
    case handles.rdbAngJuntas
        mostraCamposAngulares('on', hObject, handles);
    otherwise
        set(handles.rdbLargPulsoMicroSeg, 'Value', 0.0);
        set(handles.rdbAngJuntas, 'Value', 1.0);
        mostraCamposAngulares('on', hObject, handles);
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

% --- Executes on button press in chkComVelocidades.
function chkComVelocidades_Callback(hObject, eventdata, handles)
% hObject    handle to chkComVelocidades (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkComVelocidades


% --- Executes on button press in chkComAceleracoes.
function chkComAceleracoes_Callback(hObject, eventdata, handles)
% hObject    handle to chkComAceleracoes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkComAceleracoes



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

% Adiciona os comandos VEL de cada junta
listaComandosVel = [];
tamListaComandosVel = 0;
incluiVelocidade = get(handles.chkComVelocidades, 'Value') == 1;
if incluiVelocidade
    for i = 1:6
        campoVel = ['edt' juntas(i,:) 'Vel'];
        velocidade = str2double(get(handles.(campoVel),'String'));
        cmdVEL = ['[VEL' juntas(i,:) sprintf('%04d',velocidade) ']'];
        cmdVELcell = {cmdVEL};
        listaComandosVel = [listaComandosVel; cmdVELcell];
        tamListaComandosVel = 6;
    end
end

% Adiciona os comandos ACL de cada junta
listaComandosAcl = [];
tamListaComandosAcl = 0;
incluiAceleracao = get(handles.chkComAceleracoes, 'Value') == 1;
if incluiAceleracao
    for i = 1:6
        campoAcl = ['edt' juntas(i,:) 'Acl'];
        aceleracao = str2double(get(handles.(campoAcl),'String'));
        cmdACL = ['[ACL' juntas(i,:) sprintf('%04d',aceleracao) ']'];
        cmdACLcell = {cmdACL};
        listaComandosAcl = [listaComandosAcl; cmdACLcell];
        tamListaComandosAcl = 6;
    end
end

% Adiciona o comando JST
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
if tamSeqCom > 0 && ~isempty(index_selected) && index_selected <= tamSeqCom
    if index_selected == tamSeqCom
        comandos = [comandos; listaComandosVel; listaComandosAcl; cmdJSTcell];
    else
        comandosAntes = comandos(1:index_selected);
        comandosDepois = comandos(index_selected+1:tamSeqCom);
        comandos = [comandosAntes; listaComandosVel; listaComandosAcl; cmdJSTcell; comandosDepois];
    end
    index_selected = index_selected+tamListaComandosVel+tamListaComandosAcl+1;
    set(handles.listSequenciaComandos,'String',comandos, 'Value', index_selected);
else
    comandos = [listaComandosVel; listaComandosAcl; cmdJSTcell];
    set(handles.listSequenciaComandos,'String',comandos, 'Value', 1);
    index_selected = tamListaComandosVel+tamListaComandosAcl+1;
    set(handles.listSequenciaComandos,'String',comandos, 'Value', index_selected);
end


% --- Executes on button press in botaoNovaSequencia.
function botaoNovaSequencia_Callback(hObject, eventdata, handles)
% hObject    handle to botaoNovaSequencia (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.listSequenciaComandos,'String','');
set(handles.uipSeqComandos, 'Title', handles.titleSeqComandos);


% --- Executes on button press in botaoCarregarSeq.
function botaoCarregarSeq_Callback(hObject, eventdata, handles)
global arquivoSeqComandos;
global filenameSeqComandos;
% hObject    handle to botaoCarregarSeq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile( ...
{'*.seq', 'Sequ�ncia de Comandos (*.seq)';...
 '*.txt','Arquivo Texto (*.txt)';
 '*.*',  'All Files (*.*)'},...
 'Carregar Sequ�ncia de Comandos');

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
    filenameSeqComandos = filename;
    tituloSeqComandos = [handles.titleSeqComandos ' (' filenameSeqComandos ')'];
    arquivoSeqComandos = arquivo;
    set(handles.uipSeqComandos,'Title',tituloSeqComandos);
    fclose(fileID);
end



% --- Executes on button press in botaoSalvarSeq.
function botaoSalvarSeq_Callback(hObject, eventdata, handles)
% hObject    handle to botaoSalvarSeq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global arquivoSeqComandos;
global filenameSeqComandos;
comandos = get(handles.listSequenciaComandos,'String');
tam = size(comandos);
tamSeqCom = tam(1);
if tamSeqCom > 0
    [filename, pathname] = uiputfile(...
    {'*.seq', 'Sequ�ncia de Comandos (*.seq)';...
     '*.txt','Arquivo Texto (*.txt)';
     '*.*',  'All Files (*.*)'},...
     'Salvar Sequ�ncia de Comandos',...
     arquivoSeqComandos);
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
        set(handles.listSequenciaComandos,'String', comandos, 'Value', 1);
        filenameSeqComandos = filename;
        tituloSeqComandos = [handles.titleSeqComandos ' (' filenameSeqComandos ')'];
        arquivoSeqComandos = arquivo;
        set(handles.uipSeqComandos,'Title',tituloSeqComandos);
        fclose(fileID);
    end   
    
else
    disp('Sequ�ncia vazia');
end


function habBotoesComando(estadoHab, hObject, handles)

set(handles.botaoExecutarSeq, 'Enable', estadoHab);
set(handles.botaoContinuar, 'Enable', estadoHab);
set(handles.botaoExecutarLoop, 'Enable', estadoHab);
set(handles.botaoContinuarLoop, 'Enable', estadoHab);
set(handles.botaoNovaSequencia, 'Enable', estadoHab);
set(handles.botaoAdicionarComando, 'Enable', estadoHab);
set(handles.botaoAdicionarPosCorrente, 'Enable', estadoHab);
set(handles.botaoEditarComando, 'Enable', estadoHab);
set(handles.botaoRemoverComando, 'Enable', estadoHab);
set(handles.botaoCarregarSeq, 'Enable', estadoHab);
set(handles.botaoSalvarSeq, 'Enable', estadoHab);
set(handles.botaoComandoUp, 'Enable', estadoHab);
set(handles.botaoComandoDown, 'Enable', estadoHab);



% --- Executes on button press in botaoExecutarSeq.
function botaoExecutarSeq_Callback(hObject, eventdata, handles)
% hObject    handle to botaoExecutarSeq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global seqEmExecucao;
global filenameSeqComandos;
seqEmExecucao = true;
guidata(hObject, handles);
comandos = cellstr(get(handles.listSequenciaComandos,'String'));
[tamSeqCom,~] = size(comandos);
if tamSeqCom > 0
    habBotoesComando('Off', hObject, handles);
    set(handles.uipSeqComandos, 'Title', [handles.titleSeqComandos ' (' filenameSeqComandos ') - Em execu��o']);
%     item_selected = items{index_selected};
%     display(item_selected);
      %index_selected = get(handles.listSequenciaComandos,'Value');
    for j = 1:tamSeqCom
        % Sai do la�o ao clicar no bot�o Parar
        if seqEmExecucao == false
            break;
        end
        set(handles.listSequenciaComandos, 'Value', j);
        parserComandos(comandos{j}, hObject, eventdata, handles);
    end
    set(handles.uipSeqComandos, 'Title', [handles.titleSeqComandos ' (' filenameSeqComandos ')']);
    habBotoesComando('On', hObject, handles);
end


% --- Executes on button press in botaoContinuar.
function botaoContinuar_Callback(hObject, eventdata, handles)
% hObject    handle to botaoContinuar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global seqEmExecucao;
global filenameSeqComandos;
seqEmExecucao = true;
guidata(hObject, handles);
comandos = cellstr(get(handles.listSequenciaComandos,'String'));
[tamSeqCom,~] = size(comandos);
if tamSeqCom > 0
    set(handles.uipSeqComandos, 'Title', [handles.titleSeqComandos ' (' filenameSeqComandos ') - Continuando Execu��o']);
    habBotoesComando('Off', hObject, handles);
%     item_selected = items{index_selected};
%     display(item_selected);
    index_selected = get(handles.listSequenciaComandos,'Value');
    for j = index_selected:tamSeqCom
        % Sai do la�o ao clicar no bot�o Parar
        if seqEmExecucao == false
            break;
        end
        set(handles.listSequenciaComandos, 'Value', j);
        parserComandos(comandos{j}, hObject, eventdata, handles);
    end
    set(handles.uipSeqComandos, 'Title', [handles.titleSeqComandos ' (' filenameSeqComandos ')']);
    habBotoesComando('On', hObject, handles);
end


% --- Executes on button press in botaoExecutarLoop.
function botaoExecutarLoop_Callback(hObject, eventdata, handles)
% hObject    handle to botaoExecutarLoop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global seqEmExecucao;
global filenameSeqComandos;
seqEmExecucao = true;
guidata(hObject, handles);
comandos = cellstr(get(handles.listSequenciaComandos,'String'));
[tamSeqCom,~] = size(comandos);
if tamSeqCom > 0
    set(handles.uipSeqComandos, 'Title', [handles.titleSeqComandos ' (' filenameSeqComandos ') - Em loop']);
    habBotoesComando('Off', hObject, handles);
%     item_selected = items{index_selected};
%     display(item_selected);
      %index_selected = get(handles.listSequenciaComandos,'Value');
    while seqEmExecucao == true
        for j = 1:tamSeqCom
            % Sai do la�o ao clicar no bot�o Parar
            if seqEmExecucao == false
                break;
            end
            set(handles.listSequenciaComandos, 'Value', j);
            parserComandos(comandos{j}, hObject, eventdata, handles);
        end
    end
    set(handles.uipSeqComandos, 'Title', [handles.titleSeqComandos ' (' filenameSeqComandos ')']);
    habBotoesComando('On', hObject, handles);
end



% --- Executes on button press in botaoContinuarLoop.
function botaoContinuarLoop_Callback(hObject, eventdata, handles)
% hObject    handle to botaoContinuarLoop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global seqEmExecucao;
global filenameSeqComandos;
seqEmExecucao = true;
guidata(hObject, handles);
comandos = cellstr(get(handles.listSequenciaComandos,'String'));
[tamSeqCom,~] = size(comandos);
if tamSeqCom > 0
    set(handles.uipSeqComandos, 'Title', [handles.titleSeqComandos ' (' filenameSeqComandos ') - Continuando Loop']);
    habBotoesComando('Off', hObject, handles);
%     item_selected = items{index_selected};
%     display(item_selected);
    index_selected = get(handles.listSequenciaComandos,'Value');
    while seqEmExecucao == true    
        for j = index_selected:tamSeqCom
            % Sai do la�o ao clicar no bot�o Parar
            if seqEmExecucao == false
                break;
            end
            set(handles.listSequenciaComandos, 'Value', j);
            parserComandos(comandos{j}, hObject, eventdata, handles);
        end
        index_selected = 1;
    end
    set(handles.uipSeqComandos, 'Title', [handles.titleSeqComandos ' (' filenameSeqComandos ')']);
    habBotoesComando('On', hObject, handles);
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
    disp('Sequ�ncia Vazia');
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
    disp('Sequ�ncia Vazia');
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
    disp('Sequ�ncia vazia ou com apenas 1 item, ou primeiro item selecionado.');
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
    disp('Sequ�ncia vazia ou com apenas 1 item, ou �ltimo item selecionado.');
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
    parserComandos(comandos{index_selected}, hObject, eventdata, handles);
end



%--- Fun��o para interpretar e executar os comandos da lista de comandos
function parserComandos(comandoCorrente, hObject, eventdata, handles)
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
                    switch(comando)
                        case 'VEL'
                            campo = ['edt' junta 'Vel'];
                            set(handles.(campo),'String',num2str(valorASetar));
                            drawnow;
                            converteVelTmpPulsoParaGrausPorSeg_Callback(handles.(campo), eventdata, handles);
                        case 'ACL'
                            campo = ['edt' junta 'Acl'];
                            set(handles.(campo),'String',num2str(valorASetar));
                            drawnow;
                            converteAclTmpPulsoParaGrausPorSegQuad_Callback(handles.(campo), eventdata, handles);
                    end              
                else
                    valorASetar = -1; % Apenas obter valor de velocidade ou acelera��o
                end
                comandoVELOuACL(comando, junta, valorASetar, hObject, handles);

            % Comando delay (n�o existe na placa de controle) [DLYXXXX], XXXX =
            % tempo em milissegundos. [DLY] pausa at� que o usu�rio pressione
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
    elseif tamComandoCorrente > 0 %% A ser encarado como coment�rio
        disp(['Coment�rio: ' comandoCorrente]);
    end


    
%-------------------------------------------------------
% Fun��es de Obten��o de Resposta/Feedback dos Comandos
%-------------------------------------------------------


%---
function ObterFeedBackMultiJuntas(hObject, handles)

global juntas;

cmdGetMovingState = hex2dec('93');

fwrite(handles.serConn, cmdGetMovingState);
movingState = fread(handles.serConn,1);
anguloAtualJunta = [0,0,0,0,0,0];

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
            converteTmpPulsoParaGraus_Callback(handles.(campoEditAtual), 0, handles);
            campoGraus = [campoEditAtual 'Graus'];
            anguloAtualJunta(i) = str2double(get(handles.(campoGraus),'String'));
            
            %Calcula posicao atual da garra
            posGarra = posicaoGarra(anguloAtualJunta(1), anguloAtualJunta(2), anguloAtualJunta(3), anguloAtualJunta(4), anguloAtualJunta(5));

            set(handles.edtPosXAtual, 'String', num2str(posGarra(1)));
            set(handles.edtPosYAtual, 'String', num2str(posGarra(2)));
            set(handles.edtPosZAtual, 'String', num2str(posGarra(3)));
            set(handles.edtRxAtual, 'String', num2str(posGarra(4)));
            set(handles.edtRyAtual, 'String', num2str(posGarra(5)));
            set(handles.edtRzAtual, 'String', num2str(posGarra(6)));
            drawnow;
        end
    end
    fprintf('\n')  
    
    fwrite(handles.serConn, cmdGetMovingState);
    movingState = fread(handles.serConn,1);
end

anguloAlvoJunta = [0,0,0,0,0,0];

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
        converteTmpPulsoParaGraus_Callback(handles.(campoEditAtual), 0, handles);
        campoGraus = [campoEditAtual 'Graus'];
        anguloAtualJunta(i) = str2double(get(handles.(campoGraus),'String'));
        campoEditAlvo = ['edt' juntas(i,:) 'Alvo'];
        set(handles.(campoEditAlvo),'String',num2str(posicao));
        drawnow;
        converteTmpPulsoParaGraus_Callback(handles.(campoEditAlvo), 0, handles);
        campoGrausAlvo = [campoEditAlvo 'Graus'];
        anguloAlvoJunta(i) = str2double(get(handles.(campoGrausAlvo),'String'));
        
        posGarraAtual = posicaoGarra(anguloAtualJunta(1), anguloAtualJunta(2), anguloAtualJunta(3), anguloAtualJunta(4), anguloAtualJunta(5));
        posGarraAlvo = posicaoGarra(anguloAlvoJunta(1), anguloAlvoJunta(2), anguloAlvoJunta(3), anguloAlvoJunta(4), anguloAlvoJunta(5));

        set(handles.edtPosXAtual, 'String', num2str(posGarraAtual(1)));
        set(handles.edtPosYAtual, 'String', num2str(posGarraAtual(2)));
        set(handles.edtPosZAtual, 'String', num2str(posGarraAtual(3)));
        set(handles.edtRxAtual, 'String', num2str(posGarraAtual(4)));
        set(handles.edtRyAtual, 'String', num2str(posGarraAtual(5)));
        set(handles.edtRzAtual, 'String', num2str(posGarraAtual(6)));

        set(handles.edtPosXAlvo, 'String', num2str(posGarraAlvo(1)));
        set(handles.edtPosYAlvo, 'String', num2str(posGarraAlvo(2)));
        set(handles.edtPosZAlvo, 'String', num2str(posGarraAlvo(3)));
        set(handles.edtRxAlvo, 'String', num2str(posGarraAlvo(4)));
        set(handles.edtRyAlvo, 'String', num2str(posGarraAlvo(5)));
        set(handles.edtRzAlvo, 'String', num2str(posGarraAlvo(6)));
        drawnow;
    end
end
fprintf('\n')
guidata(hObject, handles);


%---
function ObterFeedBackJunta(junta, hObject, handles)
global juntas;

anguloAlvoJunta = [0 0 0 0 0 0];
anguloAtualJunta = [0 0 0 0 0 0];
for i=1:6
    campoAnguloAtual = ['edt' juntas(i,:) 'AtualGraus'];
    campoAnguloAlvo = ['edt' juntas(i,:) 'AlvoGraus'];
    anguloAtualJunta(i) = str2double(get(handles.(campoAnguloAtual), 'String'));
    anguloAlvoJunta(i) = str2double(get(handles.(campoAnguloAlvo), 'String'));
end

switch(junta)
    case {'J0','J1','J2','J3','J4'}
        jnt = str2double(junta(2))+1;
        canalMM = hex2dec(dec2hex(jnt-1));
    case 'GR'
        jnt = 6;
        canalMM = hex2dec('05');
end

campoEditAtual = ['edt' juntas(jnt,:) 'Atual'];
campoEditAtualGraus = [campoEditAtual 'Graus'];

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
        
        set(handles.(campoEditAtual),'String',num2str(posicao));
        drawnow;
        converteTmpPulsoParaGraus_Callback(handles.(campoEditAtual), 0, handles);
        anguloAtualJunta(jnt) = str2double(get(handles.(campoEditAtualGraus), 'String'));
    end
    fprintf('\n')
    
    %Calcula posicao atual da garra
    posGarra= posicaoGarra(anguloAtualJunta(1), anguloAtualJunta(2), anguloAtualJunta(3), anguloAtualJunta(4), anguloAtualJunta(5));

    set(handles.edtPosXAtual, 'String', num2str(posGarra(1)));
    set(handles.edtPosYAtual, 'String', num2str(posGarra(2)));
    set(handles.edtPosZAtual, 'String', num2str(posGarra(3)));
    set(handles.edtRxAtual, 'String', num2str(posGarra(4)));
    set(handles.edtRyAtual, 'String', num2str(posGarra(5)));
    set(handles.edtRzAtual, 'String', num2str(posGarra(6)));
    drawnow;
    
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
    converteTmpPulsoParaGraus_Callback(handles.(campoEditAtual), 0, handles);
    anguloAtualJunta(jnt) = str2double(get(handles.(campoEditAtualGraus), 'String'));
    campoEditAlvo = ['edt' juntas(jnt,:) 'Alvo'];
    set(handles.(campoEditAlvo),'String',num2str(posicao));
    converteTmpPulsoParaGraus_Callback(handles.(campoEditAlvo), 0, handles);
    campoEditAlvoGraus = [campoEditAlvo 'Graus'];
    anguloAlvoJunta(jnt) = str2double(get(handles.(campoEditAlvoGraus), 'String'));
    drawnow;
    
    posGarraAtual = posicaoGarra(anguloAtualJunta(1), anguloAtualJunta(2), anguloAtualJunta(3), anguloAtualJunta(4), anguloAtualJunta(5));
    posGarraAlvo = posicaoGarra(anguloAlvoJunta(1), anguloAlvoJunta(2), anguloAlvoJunta(3), anguloAlvoJunta(4), anguloAlvoJunta(5));

    set(handles.edtPosXAtual, 'String', num2str(posGarraAtual(1)));
    set(handles.edtPosYAtual, 'String', num2str(posGarraAtual(2)));
    set(handles.edtPosZAtual, 'String', num2str(posGarraAtual(3)));
    set(handles.edtRxAtual, 'String', num2str(posGarraAtual(4)));
    set(handles.edtRyAtual, 'String', num2str(posGarraAtual(5)));
    set(handles.edtRzAtual, 'String', num2str(posGarraAtual(6)));

    set(handles.edtPosXAlvo, 'String', num2str(posGarraAlvo(1)));
    set(handles.edtPosYAlvo, 'String', num2str(posGarraAlvo(2)));
    set(handles.edtPosZAlvo, 'String', num2str(posGarraAlvo(3)));
    set(handles.edtRxAlvo, 'String', num2str(posGarraAlvo(4)));
    set(handles.edtRyAlvo, 'String', num2str(posGarraAlvo(5)));
    set(handles.edtRzAlvo, 'String', num2str(posGarraAlvo(6)));
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
converteTmpPulsoParaGraus_Callback(handles.edtGRAlvo, 0, handles);
%atual
comandoPosicionarJunta('GR', alvo, hObject, handles);


%---
function comandoFecharGarra(hObject, handles)
tabelaPosLimitesData = get(handles.tabelaPosLimites,'Data');
alvo = tabelaPosLimitesData(6,2);
%alvo
set(handles.edtGRAlvo, 'String',num2str(alvo));
drawnow;
converteTmpPulsoParaGraus_Callback(handles.edtGRAlvo, 0, handles);
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
converteTmpPulsoParaGraus_Callback(handles.(campoEditAlvo), 0, handles);
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
    converteTmpPulsoParaGraus_Callback(handles.(campoEditAlvo), 0, handles);
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
    converteTmpPulsoParaGraus_Callback(handles.(campoEditAlvo), 0, handles);
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
        converteTmpPulsoParaGraus_Callback(handles.(campoEditAlvo), 0, handles);
        campoEditAtual = ['edt' juntas(i,:) 'Atual'];
        set(handles.(campoEditAtual),'String',num2str(posicao));
        drawnow;
        converteTmpPulsoParaGraus_Callback(handles.(campoEditAtual), 0, handles);
    end
end
fprintf('\n');


%---
function comandoPosicionarTodasJuntas(hObject, handles)
juntas = ['J0'; 'J1'; 'J2'; 'J3'; 'J4'; 'GR'];

arrayBytesAlvos = repmat(hex2dec('00'), 1, 12);

enviarComVelAcl = strcmp(get(hObject,'Tag'),'botaoMoverComVelAcl');

% Envia velocidades e acelera��es e monta o comando JST
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
%posi��o em microssegundos
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
    % Envia velocidades e acelera��es
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



% -----------------------------------------
% Fun��es de callback de convers�es para os campos
% -----------------------------------------

function converteGrausParaTmpPulso_Callback(hObject, eventdata, handles)
% hObject    handle to edtJ0AlvoGraus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtJ0AlvoGraus as text
%        str2double(get(hObject,'String')) returns contents of edtJ0AlvoGraus as a double
global juntas

campo = get(hObject, 'Tag');
tamCampo = length(campo);
campoTmpPulso = campo(1:tamCampo-5);
junta = campo(4:5);

idxJunta = 0;

for i=1:6
    if(strcmp(junta,juntas(i,:)))
        idxJunta = i;
    end
end

valorDoCampo = get(hObject,'String');
valorGraus = str2double(valorDoCampo);

if(~isnan(valorGraus))
    a = handles.coeffAng(idxJunta);
    b = handles.offsetAng(idxJunta);
    
    valorTempoPulso = (valorGraus-b)/a;
    valorTempoPulso = round(valorTempoPulso);
    
    tmpMax = handles.tempoPulsoMax(idxJunta);
    tmpMin = handles.tempoPulsoMin(idxJunta);
    
    if(valorTempoPulso > tmpMax)
        valorTempoPulso = tmpMax;
    elseif(valorTempoPulso < tmpMin)
        valorTempoPulso = tmpMin;
    end
    
    set(handles.(campoTmpPulso), 'String', num2str(valorTempoPulso));
    drawnow;
    
    %recalcula o valor em graus com base no que foi obtido em tempo de
    %pulso
    valorGraus = a * valorTempoPulso + b;

    set(hObject, 'String', num2str(valorGraus));
    drawnow;
else
    set(hObject, 'String', '0');
    drawnow;
end


function converteTmpPulsoParaGraus_Callback(hObject, eventdata, handles)
% hObject    handle to edtJ0Alvo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtJ0Alvo as text
%        str2double(get(hObject,'String')) returns contents of edtJ0Alvo as
%        a double
global juntas

campo = get(hObject, 'Tag');
campoGraus = [campo 'Graus'];
junta = campo(4:5);

idxJunta = 0;

for i=1:6
    if(strcmp(junta,juntas(i,:)))
        idxJunta = i;
    end
end

valorTempoPulso = str2double(get(hObject,'String'));

if(valorTempoPulso > 0)
    
    valorGraus = handles.coeffAng(idxJunta) * valorTempoPulso + handles.offsetAng(idxJunta);
    
    set(handles.(campoGraus), 'String', num2str(valorGraus));
    drawnow;
else
    set(handles.(campoGraus), 'String', '-');
    drawnow;
end


%---
function converteVelTmpPulsoParaGrausPorSeg_Callback(hObject, eventdata, handles)
global juntas

campo = get(hObject, 'Tag');
campoGrausPorSeg = [campo 'GrausPorSeg'];
junta = campo(4:5);

idxJunta = 0;

for i=1:6
    if(strcmp(junta,juntas(i,:)))
        idxJunta = i;
    end
end

valorVelTmpPulso = str2double(get(hObject,'String'));

if(valorVelTmpPulso >= 0)
    if (valorVelTmpPulso > handles.velocidadesMax(idxJunta))
        valorVelTmpPulso = handles.velocidadesMax(idxJunta);
        set(hObject,'String',num2str(valorVelTmpPulso));
        drawnow;
    end
    incrementoAng = handles.incrementosAng(idxJunta);
    velGrausPorSeg = valorVelTmpPulso * incrementoAng * 10^2;

    set(handles.(campoGrausPorSeg), 'String', num2str(velGrausPorSeg));
    drawnow;
else
    set(handles.(campoGrausPorSeg), 'String', '0');
    drawnow;
end


%---
function converteGrausPorSegParaVelTmpPulso_Callback(hObject, eventdata, handles)
global juntas

campo = get(hObject, 'Tag');
tamCampo = length(campo);
campoVelTmpPulso = campo(1:tamCampo-11);
junta = campo(4:5);

idxJunta = 0;

for i=1:6
    if(strcmp(junta,juntas(i,:)))
        idxJunta = i;
    end
end

valorDoCampo = get(hObject,'String');
valorGrausPorSeg = str2double(valorDoCampo);

if(~isnan(valorGrausPorSeg)) 
    incrementoAng = handles.incrementosAng(idxJunta);
    valorVelTmpPulso = valorGrausPorSeg / (incrementoAng * 10^2);
    valorVelTmpPulso = round(valorVelTmpPulso);
    
    if (valorVelTmpPulso > handles.velocidadesMax(idxJunta))
        valorVelTmpPulso = handles.velocidadesMax(idxJunta);
    end
    
    set(handles.(campoVelTmpPulso), 'String', num2str(valorVelTmpPulso));
    drawnow;
    
    valorGrausPorSeg = valorVelTmpPulso * incrementoAng * 10^2;

    set(hObject, 'String', num2str(valorGrausPorSeg));
    drawnow;
else
    set(hObject, 'String', '0');
    drawnow;
end



%---
function converteAclTmpPulsoParaGrausPorSegQuad_Callback(hObject, eventdata, handles)
global juntas

campo = get(hObject, 'Tag');
campoGrausPorSegQuad = [campo 'GrausPorSegQuad'];
junta = campo(4:5);

idxJunta = 0;

for i=1:6
    if(strcmp(junta,juntas(i,:)))
        idxJunta = i;
    end
end

valorAclTmpPulso = str2double(get(hObject,'String'));

if(valorAclTmpPulso >= 0)
    if (valorAclTmpPulso > handles.aceleracoesMax(idxJunta))
        valorAclTmpPulso = handles.aceleracoesMax(idxJunta);
    end
    
    incrementoAng = handles.incrementosAng(idxJunta);
    valorGrausPorSegQuad = valorAclTmpPulso * incrementoAng / (10*10^(-3)) / (80*10^(-3));

    set(handles.(campoGrausPorSegQuad), 'String', num2str(valorGrausPorSegQuad));
    drawnow;
else
    set(handles.(campoGrausPorSegQuad), 'String', '0');
    drawnow;
end



%---
function converteGrausPorSegQuadParaAclTmpPulso_Callback(hObject, eventdata, handles)
global juntas

campo = get(hObject, 'Tag');
tamCampo = length(campo);
campoAclTmpPulso = campo(1:tamCampo-15);
junta = campo(4:5);

idxJunta = 0;

for i=1:6
    if(strcmp(junta,juntas(i,:)))
        idxJunta = i;
    end
end

valorDoCampo = get(hObject,'String');
valorGrausPorSegQuad = str2double(valorDoCampo);

if(~isnan(valorGrausPorSegQuad)) 
    incrementoAng = handles.incrementosAng(idxJunta);
    valorAclTmpPulso = valorGrausPorSegQuad / (incrementoAng / (10*10^(-3)) / (80*10^(-3)));
    valorAclTmpPulso = round(valorAclTmpPulso);
    
    if (valorAclTmpPulso > handles.aceleracoesMax(idxJunta))
        valorAclTmpPulso = handles.aceleracoesMax(idxJunta);
    end
    
    set(handles.(campoAclTmpPulso), 'String', num2str(valorAclTmpPulso));
    drawnow;
    
    valorGrausPorSegQuad = valorAclTmpPulso * incrementoAng / (10*10^(-3)) / (80*10^(-3));

    set(hObject, 'String', num2str(valorGrausPorSegQuad));
    drawnow;
else
    set(hObject, 'String', '0');
    drawnow;
end


%---------------------------------
% Fun��es para cinem�tica direta
%-----------------------------------

%-- Cinem�tica da junta 0 at� a junta 4. �ngulos em graus
function [T] = CinematicaDireta(teta1graus, teta2graus, teta3graus, teta4graus, teta5graus)
teta1 = teta1graus * pi / 180;
teta2 = teta2graus * pi / 180;
teta3 = teta3graus * pi / 180;
teta4 = teta4graus * pi / 180;
teta5 = teta5graus * pi / 180;

s1 = sin(teta1);
s2 = sin(teta2);
s3 = sin(teta3);
s4 = sin(teta4);
s5 = sin(teta5);

c1 = cos(teta1);
c2 = cos(teta2);
c3 = cos(teta3);
c4 = cos(teta4);
c5 = cos(teta5);

s23 = c2*s3 + c3*s2;
c23 = c2*c3 - s2*s3;
c234 = c23*c4 - s23*s4;
s234 = s23*c4 + c23*s4;

r11 = c1*c234*c5 + s1*s5;
r21 = s1*c234*c5 - c1*s5;
r31 = s234*c5;
r12 =  s1*c5 - c1*c234*s5;
r22 = -c1*c5 - s1*c234*s5;
r32 = -s234*s5;
r13 = c1*s234;
r23 = s1*s234;
r33 = -c234;

f = 11.675*c2 + 5.825*c23 + 0.45*c234 + 8.633297*s234;

px = 2.327067*s1 + c1*f;
py = 2.327067*c1 + s1*f;
pz = 11.675*s2 + 5.825*s23 + 0.45*s234 - 8.633297*c234;

T = [[r11 r12 r13 px];...
     [r21 r22 r23 py];...
     [r31 r32 r33 pz];...
     [  0   0   0  1]];
 
 
%-- Matriz para calcular a posi��o corrente da garra. �ngulos em graus.
%-- A posi��o da garra � a posi��o do topo de sua base.
function [T] = matrizPosGarra(teta1graus, teta2graus, teta3graus, teta4graus, teta5graus)

matrizBaseParaJ0 = [[1 0 0        0];...
                    [0 1 0        0];...
                    [0 0 1 17.41098];...
                    [0 0 0        1]];
                    
matrizPulsoParaGarra = [[1 0 0   0];...
                        [0 1 0   0];...
                        [0 0 1 7.5];...
                        [0 0 0   1]];
                    
T = matrizBaseParaJ0 ...
    * CinematicaDireta(teta1graus, teta2graus, teta3graus, teta4graus, teta5graus) ...
    * matrizPulsoParaGarra;
%T = CinematicaDireta(teta1graus, teta2graus, teta3graus, teta4graus, teta5graus);


%-- Fun��o para calcular a posi��o da garra em X, Y, Z da base e rota��es
%nestes mesmos eixos (gama, beta, alfa) em graus em nota��o de eixos fixos
function [posicao] = posicaoGarra(teta1graus, teta2graus, teta3graus, teta4graus, teta5graus)

Mgarra = matrizPosGarra(teta1graus, teta2graus, teta3graus, teta4graus, teta5graus);

R = Mgarra(1:3,1:3);

X = Mgarra(1,4);
Y = Mgarra(2,4);
Z = Mgarra(3,4);

beta = atan2(-R(3,1),sqrt(R(1,1)^2+R(1,2)^2)) * 180 / pi;

if(beta == 90)
    alfa = 0;
    gama = atan2(R(1,2),R(2,2)) * 180 / pi;
elseif(beta == -90)
    alfa = 0;
    gama = -atan2(R(1,2),R(2,2));
else
    cbeta = cos(beta * pi / 180);
    alfa = atan2(R(2,1)/cbeta, R(1,1)/cbeta) * 180 / pi;
    gama = atan2(R(3,2)/cbeta, R(3,3)/cbeta) * 180 / pi;
end

posicao = [X, Y, Z, gama, beta, alfa];


%-- Fun��o de cinem�tica inversa para calcular os �ngulos das juntas com base nas coordenadas x,
%y, z e nas rota��es em X, Y e Z (gama, beta e alfa) da garra
function [angJunta, posAjustada] = angJuntas(x, y, z, gamaGraus, betaGraus, alfaGraus)

gama = gamaGraus * pi /180;
beta = betaGraus * pi /180;
alfa = alfaGraus * pi /180;

sgama = sin(gama);
sbeta = sin(beta);
salfa = sin(alfa);

cgama = cos(gama);
cbeta = cos(beta);
calfa = cos(alfa);

% r11 = calfa * cbeta;
% r21 = salfa * cbeta;
% r31 = -sbeta;

r12 = calfa * sbeta * sgama - salfa * cgama;
r22 = salfa * sbeta * sgama + calfa * cgama;
r32 = cbeta * sgama;
r13 = calfa * sbeta * cgama + salfa * sgama;
r23 = salfa * sbeta * cgama - calfa * sgama;
r33 = cbeta * sgama;

px = x - 7.5 * r13;
py = y - 7.5 * r23;
pz = z - 7.5 * r33 - 17.41098;

px2py2 = px^2 + py^2;
sqrtpx2py2 = sqrt(px2py2);
% Projetando o ponto desejado no plano do bra�o. Esta proje��o ser� a que a
% garra poder� realmente assumir (ver cap. 4 do craig - The Yasukawa
% Motoman L-3 p�gina 121)
M = 1/sqrtpx2py2 * [-py; px; 0];
Zt = [r13; r23; r33];
Yt = [r12; r22; r32];

K = cross(M,Zt);

Ztl = cross(K,M);

cteta = dot(Zt,Ztl);
steta = dot(cross(Zt,Ztl),K);

Ytl = cteta*Yt + steta*cross(K,Yt) + (1-cteta)*dot(K,Yt)*K;

Xtl = cross(Ytl,Ztl);

r11 = Xtl(1);
r21 = Xtl(2);
r31 = Xtl(3);

r12 = Ytl(1);
r22 = Ytl(2);
r32 = Ytl(3);

r13 = Ztl(1);
r23 = Ztl(2);
r33 = Ztl(3);

%Recalculando x, y e z da garra
xl = px + 7.5 * r13;
yl = py + 7.5 * r23;
zl = pz + 7.5 * r33 + 17.41098;

%recalculando gama, beta e alfa
betaGrausl = atan2(-r31, sqrt(r11^2+r21^2)) * 180 / pi;
if(betaGrausl == 90)
    alfaGrausl = 0;
    gamaGrausl = atan2(r12,r22) * 180 / pi;
elseif (betaGrausl == -90)
    alfaGrausl = 0;
    gamaGrausl = -atan2(r12,r22) * 180 / pi;
else
    cbeta = cos(betaGrausl * pi / 180);
    alfaGrausl = atan2(r21/cbeta, r11/cbeta)* 180 / pi;
    gamaGrausl = atan2(r32/cbeta, r33/cbeta)* 180 / pi;
end

posAjustada = [xl, yl, zl, gamaGrausl, betaGrausl, alfaGrausl];

teta1 = atan2(py, -px) + atan2(sqrt(px2py2 - 5.415240822489),-2.327067);
c1 = cos(teta1);
s1 = sin(teta1);
teta1 = teta1 * 180/pi;

teta5 = atan2(s1*r11 - c1*r21, s1*r12 - c1*r22) * 180/pi;

teta234 = atan2(c1*r13+s1*r23, -r33) * 180 / pi;

c3 = (px2py2 + pz^2 - 170.23625)/9249.87009453125;

s3 = sqrt(1-c3^2);

teta3 = atan2(s3, c3) * 180 / pi;

teta2 = (-atan2(pz, sqrtpx2py2) - atan2(5.825*s3, 11.675+5.825*c3)) * 180 / pi;

teta4 = teta234 - teta2 - teta3;

angJunta = [teta1, teta2, teta3, teta4, teta5];
