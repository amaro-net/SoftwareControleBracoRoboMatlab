function varargout = tela_controle_com_angulo(varargin)
% TELA_CONTROLE_COM_ANGULO M-file for tela_controle_com_angulo.fig
%      TELA_CONTROLE_COM_ANGULO, by itself, creates a new TELA_CONTROLE_COM_ANGULO or raises the existing
%      singleton*.
%
%      H = TELA_CONTROLE_COM_ANGULO returns the handle to a new TELA_CONTROLE_COM_ANGULO or the handle to
%      the existing singleton*.
%
%      TELA_CONTROLE_COM_ANGULO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TELA_CONTROLE_COM_ANGULO.M with the given input arguments.
%
%      TELA_CONTROLE_COM_ANGULO('Property','Value',...) creates a new TELA_CONTROLE_COM_ANGULO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before tela_controle_com_angulo_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to tela_controle_com_angulo_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help tela_controle_com_angulo

% Last Modified by GUIDE v2.5 21-Feb-2016 02:41:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @tela_controle_com_angulo_OpeningFcn, ...
                   'gui_OutputFcn',  @tela_controle_com_angulo_OutputFcn, ...
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


% --- Executes just before tela_controle_com_angulo is made visible.
function tela_controle_com_angulo_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to tela_controle_com_angulo (see VARARGIN)

% Choose default command line output for tela_controle_com_angulo
handles.output = hObject;
clc

tabelaPosLimitesData = [[2432 480 1405 480];[2256 768 1798 2256];[2208 800 2208 959];[2480 528 1251 1836];[2432 512 1472 1472];[2000 416 (2000+416)/2 2000]];
set(handles.tabelaPosLimites,'Data',tabelaPosLimitesData);
tabelaPosLimGrausData = [[100 -90 0 0 0]; [40 -90 0 0 0]; [0 -133 0 0 0]; [74 -126 0 0 1]; [90 -90 0 0 0]; [180 0 0 0 0]];



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

global indexPlacaSelecionada
indexPlacaSelecionada = 1; % 1 = Ready For PIC, 2 = Mini Maestro



% Update handles structure
guidata(hObject, handles);
%clear all;


% UIWAIT makes tela_controle_com_angulo wait for user response (see UIRESUME)
% uiwait(handles.figure1);



% --- Outputs from this function are returned to the command line.
function varargout = tela_controle_com_angulo_OutputFcn(hObject, eventdata, handles) 
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
global juntas

global indexPlacaSelecionada

switch (indexPlacaSelecionada)
    case 1 % Ready For PIC
        %Comando para desabilitar o eco dos caracteres pela placa de controle
        fprintf(handles.serConn,'[ECH0]');
        ObterResposta('\[ECH0\]', hObject, handles);

        comandoFRSOuCSB('FRS', '1', hObject, handles);

        comandoFRSOuCSB('CSB', '0', hObject, handles);

        botaoObterPosLimites_Callback(hObject, eventdata, handles);

        for i=1:6
            comandoVELOuACL('VEL', juntas(i,:), velocidades(i), hObject, handles);
            comandoVELOuACL('ACL', juntas(i,:), aceleracoes(i), hObject, handles);
        end

        comandoObterPosicoesAtuais(hObject, handles);
        
    case 2 % Mini Maestro 24
        for i=1:6
            comandoVELOuACL_mm('VEL', juntas(i,:), velocidades(i), hObject, handles);
            comandoVELOuACL_mm('ACL', juntas(i,:), aceleracoes(i), hObject, handles);
            converteVelTmpPulsoParaGrausPorSeg_Callback(handles.(['edt' juntas(i,:) 'Vel']), eventdata, handles);
            converteAclTmpPulsoParaGrausPorSegQuad_Callback(handles.(['edt' juntas(i,:) 'Acl']), eventdata, handles);
        end

        comandoObterPosicoesAtuais_mm(hObject, handles);

end
    


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
global juntas
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


function HabilitarComponentesReadyForPIC(estadoHab, hObject, handles)
for i = 0:7
    set(handles.(['tbLEDP' num2str(i)]), 'Enable', estadoHab);
end
set(handles.pbAtivarCmdLED, 'Enable', estadoHab);
set(handles.botaoAtualizarLeds, 'Enable', estadoHab);
set(handles.botaoObterPosLimites, 'Enable', estadoHab);
set(handles.botaoConfigurarPos, 'Enable', estadoHab);
set(handles.rdbSemFeedback, 'Enable', estadoHab);
set(handles.rdbPosCorrentes, 'Enable', estadoHab);
set(handles.rdbSinalMov, 'Enable', estadoHab);
set(handles.chkComandosJuntasBloqueantes, 'Enable', estadoHab);
set(handles.botaoResetPlacaControle, 'Enable', estadoHab);
set(handles.botaoResetarPlacaServos, 'Enable', estadoHab);

guidata(hObject, handles);


%--- estadoHab = 'On' ou 'Off'
function HabilitarComponentesConn(estadoHab, hObject, handles)
global indexPlacaSelecionada
if strcmp(estadoHab,'On')
    estadoNaoHab = 'Off';
else
    estadoNaoHab = 'On';
end
set(handles.botaoAbrirPortaSerial, 'Enable',estadoNaoHab);
HabilitarComponentes(estadoHab, hObject, handles);
switch indexPlacaSelecionada
    case 1
        HabilitarComponentesReadyForPIC(estadoHab, hObject, handles);
    case 2
        HabilitarComponentesReadyForPIC(estadoNaoHab, hObject, handles);
end

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
%Alimenta o popup com as portas seriais dispon�veis
serialInfo = instrhwinfo('serial');
set(hObject,'String',serialInfo.AvailableSerialPorts);


% --- Executes on button press in botaoFecharPortaSerial.
function botaoFecharPortaSerial_Callback(hObject, eventdata, handles)
% hObject    handle to botaoFecharPortaSerial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global indexPlacaSelecionada



if isfield(handles, 'serConn') && isvalid(handles.serConn)
    if (indexPlacaSelecionada == 1) % Ready For PIC
        fprintf(handles.serConn,'[ECH1]');
        ObterResposta('\[ECH1\]', hObject, handles);
    end
    fclose(handles.serConn);
    delete(handles.serConn);
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
global indexPlacaSelecionada

switch (indexPlacaSelecionada)
    case 1 % Ready For PIC
        comandoAbrirGarra(hObject, handles);
    case 2 % Mini Maestro 24
        comandoAbrirGarra_mm(hObject, handles);
end
guidata(hObject, handles);


% --- Executes on button press in botaoFecharGarra.
function botaoFecharGarra_Callback(hObject, eventdata, handles)
% hObject    handle to botaoFecharGarra (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global indexPlacaSelecionada

switch (indexPlacaSelecionada)
    case 1 % Ready For PIC
        comandoFecharGarra(hObject, handles);
    case 2 % Mini Maestro 24
        comandoFecharGarra_mm(hObject, handles);
end
guidata(hObject, handles);


% --- Executes on button press in botaoGarraSemiaberta.
function botaoGarraSemiaberta_Callback(hObject, eventdata, handles)
% hObject    handle to botaoGarraSemiaberta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global indexPlacaSelecionada

switch (indexPlacaSelecionada)
    case 1 % Ready For PIC
        comandoGarraSemiAberta(hObject, handles);
    case 2 % Mini Maestro 24
        comandoGarraSemiAberta_mm(hObject, handles);
end
guidata(hObject, handles);



% --- Executes on button press in botaoGirarGarraMais90.
function botaoGirarGarraMais90_Callback(hObject, eventdata, handles)
% hObject    handle to botaoGirarGarraMais90 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global indexPlacaSelecionada

switch (indexPlacaSelecionada)
    case 1 %Ready For PIC
        fprintf(handles.serConn,'[TMXJ4]');
        alvo = ReceberConfigPosicao(hObject, handles);
        %alvo
        set(handles.edtJ4Alvo, 'String',num2str(alvo));
        drawnow;
        converteTmpPulsoParaGraus_Callback(handles.edtJ4Alvo, 0, handles);
        comandoPosicionarJunta('J4', alvo, hObject, handles);
    case 2 % Mini Maestro 24
        tabelaPosLimitesData = get(handles.tabelaPosLimites,'Data');
        alvo = tabelaPosLimitesData(5,1);
        %alvo
        set(handles.edtJ4Alvo, 'String',num2str(alvo));
        drawnow;
        converteTmpPulsoParaGraus_Callback(handles.edtJ4Alvo, 0, handles);
        comandoPosicionarJunta_mm('J4', alvo, hObject, handles);
end


% --- Executes on button press in botaoGirarGarraMenos90.
function botaoGirarGarraMenos90_Callback(hObject, eventdata, handles)
% hObject    handle to botaoGirarGarraMenos90 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global indexPlacaSelecionada

switch (indexPlacaSelecionada)
    case 1
        fprintf(handles.serConn,'[TMNJ4]');
        alvo = ReceberConfigPosicao(hObject, handles);
        %alvo
        set(handles.edtJ4Alvo, 'String',num2str(alvo));
        drawnow;
        converteTmpPulsoParaGraus_Callback(handles.edtJ4Alvo, 0, handles);
        comandoPosicionarJunta('J4', alvo, hObject, handles);
    case 2
        tabelaPosLimitesData = get(handles.tabelaPosLimites,'Data');
        alvo = tabelaPosLimitesData(5,2);
        %alvo
        set(handles.edtJ4Alvo, 'String',num2str(alvo));
        drawnow;
        converteTmpPulsoParaGraus_Callback(handles.edtJ4Alvo, 0, handles);
        comandoPosicionarJunta_mm('J4', alvo, hObject, handles);
end


% --- Executes on button press in botaoGarraPosNeutra.
function botaoGarraPosNeutra_Callback(hObject, eventdata, handles)
% hObject    handle to botaoGarraPosNeutra (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global indexPlacaSelecionada

switch (indexPlacaSelecionada)
    case 1
        fprintf(handles.serConn,'[T90J4]');
        alvo = ReceberConfigPosicao(hObject, handles);
        %alvo
        set(handles.edtJ4Alvo, 'String',num2str(alvo));
        drawnow;
        converteTmpPulsoParaGraus_Callback(handles.edtJ4Alvo, 0, handles);
        comandoPosicionarJunta('J4', alvo, hObject, handles);
    case 2
        tabelaPosLimitesData = get(handles.tabelaPosLimites,'Data');
        alvo = tabelaPosLimitesData(5,3);
        %alvo
        set(handles.edtJ4Alvo, 'String',num2str(alvo));
        drawnow;
        converteTmpPulsoParaGraus_Callback(handles.edtJ4Alvo, 0, handles);
        comandoPosicionarJunta_mm('J4', alvo, hObject, handles);
end

% --- Executes on button press in botaoPosRepouso.
function botaoPosRepouso_Callback(hObject, eventdata, handles)
% hObject    handle to botaoPosRepouso (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global indexPlacaSelecionada

switch (indexPlacaSelecionada)
    case 1
        comandoRepouso(hObject, handles);
    case 2
        comandoRepouso_mm(hObject, handles);
end


% --- Executes on button press in botaoDesligaServos.
function botaoDesligaServos_Callback(hObject, eventdata, handles)
% hObject    handle to botaoDesligaServos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global indexPlacaSelecionada

switch (indexPlacaSelecionada)
    case 1
        comandoRepouso(hObject, handles);
        %pause(10)
        comandoDesligarServos(hObject, handles);
    case 2
        comandoRepouso_mm(hObject, handles);
        %pause(10)
        comandoDesligarServos_mm(hObject, handles);
end
guidata(hObject, handles);


% --- Executes on button press in botaoPosNeutraCTZ.
function botaoPosNeutraCTZ_Callback(hObject, eventdata, handles)
% hObject    handle to botaoPosNeutraCTZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global indexPlacaSelecionada

switch (indexPlacaSelecionada)
    case 1
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
    case 2
        comandoCTZ_mm('J0', hObject, handles);
        %pause(0.4)
        comandoCTZ_mm('J1', hObject, handles);
        %pause(0.4)
        comandoCTZ_mm('J2', hObject, handles);
        %pause(0.4)
        comandoCTZ_mm('J3', hObject, handles);
        %pause(0.4)
        comandoCTZ_mm('J4', hObject, handles);
        %pause(0.4)
        comandoCTZ_mm('GR', hObject, handles);
end

guidata(hObject, handles);


% --- Executes on button press in botaoPosNeutraJST.
function botaoPosNeutraJST_Callback(hObject, eventdata, handles)
% hObject    handle to botaoPosNeutraJST (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global juntas
global indexPlacaSelecionada

switch (indexPlacaSelecionada)
    case 1
        %alvo
        for i=1:6
            fprintf(handles.serConn,['[T90' juntas(i,:) ']']);
            alvo = ReceberConfigPosicao(hObject, handles);
            campoEditAlvo = ['edt' juntas(i,:) 'Alvo'];
            set(handles.(campoEditAlvo),'String',num2str(alvo));
            drawnow;
            converteTmpPulsoParaGraus_Callback(handles.(campoEditAlvo), 0, handles);
        end
        %Atual (mesmo que acionar o bot�o Mover)
        botaoMover_Callback(handles.botaoMover, eventdata, handles);
    case 2
        tabelaPosLimitesData = get(handles.tabelaPosLimites,'Data');
        for i=1:6
            alvo = tabelaPosLimitesData(i,3);
            campoEditAlvo = ['edt' juntas(i,:) 'Alvo'];
            set(handles.(campoEditAlvo),'String',num2str(alvo));
            drawnow;
            converteTmpPulsoParaGraus_Callback(handles.(campoEditAlvo), 0, handles);
        end
        %Atual
        comandoPosicionarTodasJuntas_mm(hObject, handles);
end



% --- Executes on button press in botaoObterPosicoes.
function botaoObterPosicoes_Callback(hObject, eventdata, handles)
% hObject    handle to botaoObterPosicoes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global indexPlacaSelecionada

switch (indexPlacaSelecionada)
    case 1
        comandoObterPosicoesAtuais(hObject, handles)
    case 2
        comandoObterPosicoesAtuais_mm(hObject, handles)
end


% --- Executes on button press in botaoMover.
function botaoMover_Callback(hObject, eventdata, handles)
% hObject    handle to botaoMover (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global indexPlacaSelecionada

switch (indexPlacaSelecionada)
    case 1
        comandoPosicionarTodasJuntas(hObject, handles);
    case 2
        comandoPosicionarTodasJuntas_mm(hObject, handles);
end


% --- Executes on button press in botaoMoverComVelAcl.
function botaoMoverComVelAcl_Callback(hObject, eventdata, handles)
% hObject    handle to botaoMoverComVelAcl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global indexPlacaSelecionada

switch (indexPlacaSelecionada)
    case 1
        comandoPosicionarTodasJuntas(hObject, handles);
    case 2
        comandoPosicionarTodasJuntas_mm(hObject, handles);
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles, 'serConn') && isvalid(handles.serConn)
    if (indexPlacaSelecionada == 1) % Ready For PIC
        fprintf(handles.serConn,'[ECH1]');
        ObterResposta('\[ECH1\]', hObject, handles);
    end
    fclose(handles.serConn);
    delete(handles.serConn);
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


% --- Executes on button press in botaoResetPlacaControle.
function botaoResetPlacaControle_Callback(hObject, eventdata, handles)
% hObject    handle to botaoResetPlacaControle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
button = questdlg('Ao resetar a placa de controle, a conex�o serial ser� encerrada. Deseja continuar?','RST','Sim','N�o','N�o');
if strcmp(button,'Sim')
    fprintf(handles.serConn, '[RST]');
    ObterResposta('\[RST\]', hObject, handles);
    if isfield(handles, 'serConn')
        if isvalid(handles.serConn)
            fclose(handles.serConn);
            delete(handles.serConn);
        end
    end
    HabilitarComponentesConn('Off', hObject, handles)
end


% --- Executes on button press in botaoResetarPlacaServos.
function botaoResetarPlacaServos_Callback(hObject, eventdata, handles)
% hObject    handle to botaoResetarPlacaServos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
button = questdlg('A placa Mini Maestro 24 ser� reiniciada. Deseja continuar?','RSTM','Sim','N�o','N�o');
if strcmp(button,'Sim')
    fprintf(handles.serConn, '[RSTM]');
    HabilitarComponentes('Off', hObject, handles);
    HabilitarComponentesReadyForPIC('Off', hObject, handles)
    ObterFeedBackJunta(hObject, handles);
    ObterFeedBackMultiJuntas(hObject, handles);
    ObterResposta('\[PRONTO\]', hObject, handles);
    HabilitarComponentes('On', hObject, handles);
    HabilitarComponentesReadyForPIC('On', hObject, handles)
    configuracoesIniciais(hObject, eventdata, handles);
end


% --- Executes on button press in pbAtivarCmdLED.
function pbAtivarCmdLED_Callback(hObject, eventdata, handles)
% hObject    handle to pbAtivarCmdLED (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(get(handles.pbAtivarCmdLED,'Value') == 1)
    comandoLED(hObject, handles);
end


% --- Executes on button press in botaoAtualizarLeds.
function botaoAtualizarLeds_Callback(hObject, eventdata, handles)
% hObject    handle to botaoAtualizarLeds (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
comandoLEDSemParam(hObject, handles);

% --- Executes on button press in tbLEDP0.
function tbLEDP0_Callback(hObject, eventdata, handles)
% hObject    handle to tbLEDP0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tbLEDP0
pbAtivarCmdLED_Callback(hObject, eventdata, handles)


% --- Executes on button press in tbLEDP1.
function tbLEDP1_Callback(hObject, eventdata, handles)
% hObject    handle to tbLEDP1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tbLEDP1
pbAtivarCmdLED_Callback(hObject, eventdata, handles)


% --- Executes on button press in tbLEDP2.
function tbLEDP2_Callback(hObject, eventdata, handles)
% hObject    handle to tbLEDP2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tbLEDP2
pbAtivarCmdLED_Callback(hObject, eventdata, handles)


% --- Executes on button press in tbLEDP3.
function tbLEDP3_Callback(hObject, eventdata, handles)
% hObject    handle to tbLEDP3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tbLEDP3
pbAtivarCmdLED_Callback(hObject, eventdata, handles)


% --- Executes on button press in tbLEDP4.
function tbLEDP4_Callback(hObject, eventdata, handles)
% hObject    handle to tbLEDP4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tbLEDP4
pbAtivarCmdLED_Callback(hObject, eventdata, handles)


% --- Executes on button press in tbLEDP5.
function tbLEDP5_Callback(hObject, eventdata, handles)
% hObject    handle to tbLEDP5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tbLEDP5
pbAtivarCmdLED_Callback(hObject, eventdata, handles)


% --- Executes on button press in tbLEDP6.
function tbLEDP6_Callback(hObject, eventdata, handles)
% hObject    handle to tbLEDP6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tbLEDP6
pbAtivarCmdLED_Callback(hObject, eventdata, handles)


% --- Executes on button press in tbLEDP7.
function tbLEDP7_Callback(hObject, eventdata, handles)
% hObject    handle to tbLEDP7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tbLEDP7
pbAtivarCmdLED_Callback(hObject, eventdata, handles)


% --- Executes on button press in botaoConfigurarPos.
function botaoConfigurarPos_Callback(hObject, eventdata, handles)
% hObject    handle to botaoConfigurarPos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tabelaPosLimitesData = get(handles.tabelaPosLimites,'Data');

global juntas
comandos = ['TMX'; 'TMN'; 'T90'; 'TRP'];

for idxCol = 1:4
    for idxLinha = 1:6
        ComandoPosLimite(comandos(idxCol,:), juntas(idxLinha,:), tabelaPosLimitesData(idxLinha,idxCol), hObject, handles);
    end
end

% --- Executes on button press in botaoObterPosLimites.
function botaoObterPosLimites_Callback(hObject, eventdata, handles)
% hObject    handle to botaoObterPosLimites (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global juntas
comandos = ['TMX'; 'TMN'; 'T90'; 'TRP'];

for idxCol = 1:4
    for idxLinha = 1:6
        ComandoPosLimite(comandos(idxCol,:), juntas(idxLinha,:), 0, hObject, handles);
    end
end



% --- Executes on button press in chkComandosJuntasBloqueantes.
function chkComandosJuntasBloqueantes_Callback(hObject, eventdata, handles)
% hObject    handle to chkComandosJuntasBloqueantes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of
% chkComandosJuntasBloqueantes
%comandoFRSOuCSB(comando, strValorConfig, hObject, handles)
switch(get(hObject,'Value'))
    case 0
        comandoFRSOuCSB('CSB', '0', hObject, handles);
    case 1
        comandoFRSOuCSB('CSB', '1', hObject, handles);
end

% --- Executes when selected object is changed in uipPlacaConectada.
function uipPlacaConectada_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipPlacaConectada 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
global indexPlacaSelecionada

switch (hObject)
    case handles.rdbReadyForPic
        indexPlacaSelecionada = 1;
        if isfield(handles, 'serConn') && isvalid(handles.serConn) && strcmp(handles.serConn.status, 'open')
            HabilitarComponentesReadyForPIC('On', hObject, handles)
        end
        
    case handles.rdbMiniMaestro24
        indexPlacaSelecionada = 2;
        HabilitarComponentesReadyForPIC('Off', hObject, handles)
end



% --- Executes when selected object is changed in btgFeedBack.
function btgFeedBack_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in btgFeedBack 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
switch(hObject)
    case handles.rdbSemFeedback
        comandoFRSOuCSB('FRS', '0', hObject, handles);
    case handles.rdbPosCorrentes
        comandoFRSOuCSB('FRS', '1', hObject, handles);
    case handles.rdbSinalMov
        comandoFRSOuCSB('FRS', '2', hObject, handles);
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


% --- estadoVisible = on ou off
function mostraCamposAngulares(estadoVisible, hObject, handles)
global juntas
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
global juntas
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
global indexPlacaSelecionada;
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
        switch (indexPlacaSelecionada)
            case 1 % Ready For PIC
                parserComandos(comandos{j}, hObject, eventdata, handles);
            case 2 % Mini Maestro 24
                parserComandos_mm(comandos{j}, hObject, eventdata, handles);
        end        
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
        switch (indexPlacaSelecionada)
            case 1 % Ready For PIC
                parserComandos(comandos{j}, hObject, eventdata, handles);
            case 2 % Mini Maestro 24
                parserComandos_mm(comandos{j}, hObject, eventdata, handles);
        end 
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
            switch (indexPlacaSelecionada)
                case 1 % Ready For PIC
                    parserComandos(comandos{j}, hObject, eventdata, handles);
                case 2 % Mini Maestro 24
                    parserComandos_mm(comandos{j}, hObject, eventdata, handles);
            end 
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
            switch (indexPlacaSelecionada)
                case 1 % Ready For PIC
                    parserComandos(comandos{j}, hObject, eventdata, handles);
                case 2 % Mini Maestro 24
                    parserComandos_mm(comandos{j}, hObject, eventdata, handles);
            end 
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
    switch (indexPlacaSelecionada)
        case 1 % Ready For PIC
            parserComandos(comandos{index_selected}, hObject, eventdata, handles);
        case 2 % Mini Maestro 24
            parserComandos_mm(comandos{index_selected}, hObject, eventdata, handles);
    end 
end



%--- Fun��o para interpretar e executar os comandos da lista de comandos
%pela placa Ready For PIC
function parserComandos(comandoCorrente, hObject, eventdata, handles)
global juntas
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
        case 'LED'
                for i = 5:12
                    botaoLEDCorresp = ['tbLEDP' num2str(12-i)];
                    valor = str2double(comandoCorrente(i));
                    set(handles.(botaoLEDCorresp), 'Value', valor);
                end
                comandoLED(hObject, handles);
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


%--- Fun��o para interpretar e executar os comandos da lista de comandos
%pela placa Mini Maestro 24
function parserComandos_mm(comandoCorrente, hObject, eventdata, handles)
global juntas
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
            comandoAbrirGarra_mm(hObject, handles);
        case 'GF'
            comandoFecharGarra_mm(hObject, handles);
        case 'CTZ'
            junta = comandoCorrente(5:6);
            comandoCTZ_mm(junta, hObject, handles);
        case 'JST'
            valor = [0 0 0 0 0 0];
            for i = 1:6
                iServo = 5*i;
                strValor = comandoCorrente(iServo+1:iServo+4);
                valor(i) = str2double(strValor);
            end

            for i = 1:6
                campoEditAlvo = ['edt' juntas(i,:) 'Alvo'];
                set(handles.(campoEditAlvo),'String',num2str(valor(i)));
                drawnow;
            end
            comandoPosicionarTodasJuntas_mm(hObject, handles);
        case 'RPS'
            comandoRepouso_mm(hObject, handles);
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
            comandoVELOuACL_mm(comando, junta, valorASetar, hObject, handles);

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


    
%------------------------------------------------------------------------
% Fun��es de Obten��o de Resposta/Feedback dos Comandos para a placa Mini
% Maestro 24
%------------------------------------------------------------------------


%---
function ObterFeedBackMultiJuntas_mm(hObject, handles)

global juntas

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
            converteTmpPulsoParaGraus_Callback(handles.(campoEditAtual), 0, handles);
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
        converteTmpPulsoParaGraus_Callback(handles.(campoEditAtual), 0, handles);
        campoEditAlvo = ['edt' juntas(i,:) 'Alvo'];
        set(handles.(campoEditAlvo),'String',num2str(posicao));
        drawnow;
        converteTmpPulsoParaGraus_Callback(handles.(campoEditAlvo), 0, handles);
    end
end
fprintf('\n')

guidata(hObject, handles);


%---
function ObterFeedBackJunta_mm(junta, hObject, handles)
global juntas
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
        converteTmpPulsoParaGraus_Callback(handles.(campoEditAtual), 0, handles);
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
    converteTmpPulsoParaGraus_Callback(handles.(campoEditAtual), 0, handles);
    campoEditAlvo = ['edt' juntas(jnt,:) 'Alvo'];
    set(handles.(campoEditAlvo),'String',num2str(posicao));
    converteTmpPulsoParaGraus_Callback(handles.(campoEditAlvo), 0, handles);
    drawnow;
end
fprintf('\n')

guidata(hObject, handles);



%--------------------------------------
% Comandos para a placa Mini Maestro 24
%--------------------------------------

%---
function comandoAbrirGarra_mm(hObject, handles)
tabelaPosLimitesData = get(handles.tabelaPosLimites,'Data');
alvo = tabelaPosLimitesData(6,1);
%alvo
set(handles.edtGRAlvo, 'String',num2str(alvo));
drawnow;
converteTmpPulsoParaGraus_Callback(handles.edtGRAlvo, 0, handles);
%atual
comandoPosicionarJunta_mm('GR', alvo, hObject, handles);


%---
function comandoFecharGarra_mm(hObject, handles)
tabelaPosLimitesData = get(handles.tabelaPosLimites,'Data');
alvo = tabelaPosLimitesData(6,2);
%alvo
set(handles.edtGRAlvo, 'String',num2str(alvo));
drawnow;
converteTmpPulsoParaGraus_Callback(handles.edtGRAlvo, 0, handles);
%atual
comandoPosicionarJunta_mm('GR', alvo, hObject, handles);


%---
function comandoGarraSemiAberta_mm(hObject, handles)
comandoCTZ_mm('GR', hObject, handles);


%--- junta = J0, J1, J2, J3, J4 ou GR
function comandoCTZ_mm(junta, hObject, handles)
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

ObterFeedBackJunta_mm(junta, hObject, handles);


%---
function comandoRepouso_mm(hObject, handles)
global juntas
tabelaPosLimitesData = get(handles.tabelaPosLimites,'Data');
for i=1:6
    alvo = tabelaPosLimitesData(i,4);
    campoEditAlvo = ['edt' juntas(i,:) 'Alvo'];
    set(handles.(campoEditAlvo),'String',num2str(alvo));
    drawnow;
    converteTmpPulsoParaGraus_Callback(handles.(campoEditAlvo), 0, handles);
end
%Atual
comandoPosicionarTodasJuntas_mm(hObject, handles);


%---
function comandoDesligarServos_mm(hObject, handles)
global juntas
for i=1:6
    alvo = 0;
    campoEditAlvo = ['edt' juntas(i,:) 'Alvo'];
    set(handles.(campoEditAlvo),'String',num2str(alvo));
    drawnow;
    converteTmpPulsoParaGraus_Callback(handles.(campoEditAlvo), 0, handles);
end
comandoPosicionarTodasJuntas_mm(hObject, handles);


%---
function comandoObterPosicoesAtuais_mm(hObject, handles)
global juntas

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
function comandoPosicionarTodasJuntas_mm(hObject, handles)
global juntas

arrayBytesAlvos = repmat(hex2dec('00'), 1, 12);

enviarComVelAcl = strcmp(get(hObject,'Tag'),'botaoMoverComVelAcl');

% Envia velocidades e acelera��es e monta o comando JST
for i = 1:6
    if enviarComVelAcl
        campoVEL = ['edt' juntas(i,:) 'Vel'];
        campoACL = ['edt' juntas(i,:) 'Acl'];
        velocidade = str2double(get(handles.(campoVEL),'String'));
        aceleracao = str2double(get(handles.(campoACL),'String'));
        comandoVELOuACL_mm('VEL', juntas(i,:), velocidade, hObject, handles);
        comandoVELOuACL_mm('ACL', juntas(i,:), aceleracao, hObject, handles);
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

ObterFeedBackMultiJuntas_mm(hObject, handles);


%--- Junta = J0, J1,...,J4, GR    ou  A, B, C, D, E, G; alvo: valor da
%posi��o em microssegundos
function comandoPosicionarJunta_mm(junta, alvo, hObject, handles)
global juntas
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
    comandoVELOuACL_mm('VEL', juntas(idxJunta,:), velocidade, hObject, handles);
    comandoVELOuACL_mm('ACL', juntas(idxJunta,:), aceleracao, hObject, handles);
end
% monta o set target
alvoMM = hex2dec(dec2hex(alvo * 4));
valorL = bitand(alvoMM, hex2dec('7F'));
valorH = bitand(bitshift(alvoMM,-7),hex2dec('7F')); % -7 para deslocar 7 bits para a direita

cmdSetTarget = [ hex2dec('84') canalMM valorL valorH ];

fwrite(handles.serConn, cmdSetTarget);
ObterFeedBackMultiJuntas_mm(hObject, handles);



%--- comando = VEL, ACL; junta = J0, J1,...,J4, GR;
%    valorASetar >= 0 seta valor; valorASetar = -1 apenas puxa valor da placa
%    de controle
function comandoVELOuACL_mm(comando, junta, valorASetar, hObject, handles)

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




%------------------------------------------------------------------------
% Fun��es de Obten��o de Resposta/Feedback dos Comandos para a placa Ready
% For PIC
%------------------------------------------------------------------------
%---
function ObterResposta(respostaEsperada, hObject, handles)
contador = 1;
expression = respostaEsperada;
respostaFinalReconhecida = '';

while (isempty(respostaFinalReconhecida) && contador < 5)
    feedBack = strtrim(fgetl(handles.serConn));
    respostaFinalReconhecida = regexp(feedBack,expression,'match','once'); 
    if(isempty(feedBack))
        contador = contador + 1
    else
        contador = 1;
        if(isempty(respostaFinalReconhecida))
            feedBack
        else
            respostaFinalReconhecida
        end
    end
end
guidata(hObject, handles);


%--- 
function ObterRespostaVEL_ACL(hObject, handles)
contador = 1;
expression = '\[(VEL|ACL)(J[0-5]|GR)[0-9][0-9][0-9][0-9]\]';
respostaFinalReconhecida = '';

while (isempty(respostaFinalReconhecida) && contador < 5)
    feedBack = strtrim(fgetl(handles.serConn));
    respostaFinalReconhecida = regexp(feedBack,expression,'match','once');
    if(isempty(feedBack))
        contador = contador + 1
    else
        contador = 1;
        if(isempty(respostaFinalReconhecida))
            fb = feedBack
        else
            fb = respostaFinalReconhecida
        end
        comando = fb(2:4);
        junta = fb(5:6);
        strValor = fb(7:10);
        
        if(strcmp(comando,'VEL'))
            campoEdit = ['edt' junta 'Vel'];
            valor = str2double(strValor);
            strValor = num2str(valor);
            set(handles.(campoEdit), 'String', strValor);
            drawnow;
            converteVelTmpPulsoParaGrausPorSeg_Callback(handles.(campoEdit), 0, handles);
            
        elseif (strcmp(comando,'ACL'))
            campoEdit = ['edt' junta 'Acl'];
            valor = str2double(strValor);
            strValor = num2str(valor);
            set(handles.(campoEdit), 'String', strValor);
            drawnow;
            converteAclTmpPulsoParaGrausPorSegQuad_Callback(handles.(campoEdit), 0, handles);
        else
            return;
        end
        
        
    end
end
guidata(hObject, handles);


%---
function valor = ReceberConfigPosicao(hObject, handles)
contador = 1;
expression = '\[(TMX|TMN|T90|TRP)(J[0-5]|GR)[0-9][0-9][0-9][0-9]\]';
respostaFinalReconhecida = '';

while (isempty(respostaFinalReconhecida) && contador < 5)
    feedBack = strtrim(fgetl(handles.serConn));
    respostaFinalReconhecida = regexp(feedBack,expression,'match','once');
    if(isempty(feedBack))
        contador = contador + 1
    else
        contador = 1;
        if(isempty(respostaFinalReconhecida))
            fb = feedBack
        else
            fb = respostaFinalReconhecida
        end
        
        valor = str2double(fb(7:10));
    end
end
guidata(hObject, handles);


%---
function ObterFeedBackMultiJuntas(hObject, handles)
contador = 1;
expression = '\[((JST)|(RPS)|(IN2))A[0-9][0-9][0-9][0-9]B[0-9][0-9][0-9][0-9]C[0-9][0-9][0-9][0-9]D[0-9][0-9][0-9][0-9]E[0-9][0-9][0-9][0-9]G[0-9][0-9][0-9][0-9]\]';
expressionMOV = '\[MOVA[0-9][0-9][0-9][0-9]B[0-9][0-9][0-9][0-9]C[0-9][0-9][0-9][0-9]D[0-9][0-9][0-9][0-9]E[0-9][0-9][0-9][0-9]G[0-9][0-9][0-9][0-9]\]';
respostaFinalReconhecida = '';
global juntas;

while (isempty(respostaFinalReconhecida) && contador < 5)
    feedBack = strtrim(fgetl(handles.serConn));
    respostaFinalReconhecida = regexp(feedBack,expression,'match','once'); 
    if(isempty(feedBack))
        contador = contador + 1
    else
        contador = 1;
        if(isempty(respostaFinalReconhecida))
            fb = regexp(feedBack,expressionMOV,'match','once');
        else
            fb = respostaFinalReconhecida;
        end
        
        if(~isempty(fb))
            fb
            comando = fb(2:4);
            valor = [0 0 0 0 0 0];
            for i = 1:6
                iServo = 5*i;
                strValor = fb(iServo+1:iServo+4);
                valor(i) = str2double(strValor);
            end
            
            for i = 1:6
                campoEditAtual = ['edt' juntas(i,:) 'Atual'];
                set(handles.(campoEditAtual),'String',num2str(valor(i)));
                drawnow;
                converteTmpPulsoParaGraus_Callback(handles.(campoEditAtual), 0, handles);
                if(strcmp(comando,'JST') || strcmp(comando,'IN2') || strcmp(comando,'RPS'))
                    campoEditAlvo = ['edt' juntas(i,:) 'Alvo'];
                    set(handles.(campoEditAlvo),'String',num2str(valor(i)));
                    drawnow;
                    converteTmpPulsoParaGraus_Callback(handles.(campoEditAlvo), 0, handles);
                end
            end
        else
            feedBack
        end
    end
end
guidata(hObject, handles);


%---
function ObterFeedBackJunta(hObject, handles)
contador = 1;
expression = '\[((CTZ|IN1)(J[0-4]|GR)|GA|GF)[0-9][0-9][0-9][0-9]\]';
expressionMOV = '\[MOV(J[0-4]|GR)[0-9][0-9][0-9][0-9]\]';
respostaFinalReconhecida = '';

while (isempty(respostaFinalReconhecida) && contador < 5)
    feedBack = strtrim(fgetl(handles.serConn));
    respostaFinalReconhecida = regexp(feedBack,expression,'match','once'); 
    if(isempty(feedBack))
        contador = contador + 1
    else
        contador = 1;
        if(isempty(respostaFinalReconhecida))
            fb = regexp(feedBack,expressionMOV,'match','once');
        else
            fb = respostaFinalReconhecida;
        end
        
        if(~isempty(fb))
            fb
            if fb(2) == 'G'
                idxAux = 3;
                idxAux2 = 0;
                junta = 'GR';
            else
                idxAux = 4;
                idxAux2 = 2;
                junta = fb(5:6);
            end
            comando = fb(2:idxAux);
            
            valor = str2double(fb(idxAux+idxAux2+1:idxAux+idxAux2+4));
            campoEditAtual = ['edt' junta 'Atual'];
            set(handles.(campoEditAtual), 'String', num2str(valor));
            drawnow;
            converteTmpPulsoParaGraus_Callback(handles.(campoEditAtual), 0, handles);
            if(strcmp(comando,'CTZ') || strcmp(comando,'IN1') || strcmp(comando,'GA') || strcmp(comando,'GF'))
                campoEditAlvo = ['edt' junta 'Alvo'];
                set(handles.(campoEditAlvo), 'String', num2str(valor));
                drawnow;
                converteTmpPulsoParaGraus_Callback(handles.(campoEditAlvo), 0, handles);
            end
        else
            feedBack
        end
    end
end
guidata(hObject, handles);


%---
function ObterRespostaCmdLED(hObject, handles)
contador = 1;
expression = '\[LED[0-1][0-1][0-1][0-1][0-1][0-1][0-1][0-1]\]';
respostaFinalReconhecida = '';

while (isempty(respostaFinalReconhecida) && contador < 5)
    feedBack = strtrim(fgetl(handles.serConn));
    respostaFinalReconhecida = regexp(feedBack,expression,'match','once'); 
    if(isempty(feedBack))
        contador = contador + 1
    else
        contador = 1;
        if(isempty(respostaFinalReconhecida))
            fb = feedBack
        else
            fb = respostaFinalReconhecida
            
            for i=0:7
                set(handles.(['tbLEDP' num2str(i)]),'Value',str2double(fb(12-i)));
            end
        end
    end
end
guidata(hObject, handles);



%---
function ObterRespostaFRS_CSB(hObject, handles)
contador = 1;
expression = '\[((FRS[0-2])|(CSB[0-1]))\]';
respostaFinalReconhecida = '';

while (isempty(respostaFinalReconhecida) && contador < 5)
    feedBack = strtrim(fgetl(handles.serConn));
    respostaFinalReconhecida = regexp(feedBack,expression,'match','once'); 
    if(isempty(feedBack))
        contador = contador + 1
    else
        contador = 1;
        if(isempty(respostaFinalReconhecida))
            fb = feedBack
        else
            fb = respostaFinalReconhecida
            
            comando = fb(2:4);
            valor = str2double(fb(5));
            
            switch(comando)
                case 'FRS'
                    switch(valor)
                        case 0
                            set(handles.rdbSemFeedback,'Value',1);
                            set(handles.rdbPosCorrentes,'Value',0);
                            set(handles.rdbSinalMov,'Value',0);
                        case 1
                            set(handles.rdbSemFeedback,'Value',0);
                            set(handles.rdbPosCorrentes,'Value',1);
                            set(handles.rdbSinalMov,'Value',0);
                        case 2
                            set(handles.rdbSemFeedback,'Value',0);
                            set(handles.rdbPosCorrentes,'Value',0);
                            set(handles.rdbSinalMov,'Value',1);
                    end
                case 'CSB'
                    set(handles.chkComandosJuntasBloqueantes,'Value',valor);
            end            
        end
    end
end
guidata(hObject, handles);



%--------------------------------------
% Comandos para a placa Ready For PIC
%--------------------------------------

%---
function comandoAbrirGarra(hObject, handles)
fprintf(handles.serConn,'[TMXGR]');
alvo = ReceberConfigPosicao(hObject, handles);
%alvo
set(handles.edtGRAlvo, 'String',num2str(alvo));
drawnow;
converteTmpPulsoParaGraus_Callback(handles.edtGRAlvo, 0, handles);
%atual
fprintf(handles.serConn,'[GA]');
ObterFeedBackJunta(hObject, handles);


%---
function comandoFecharGarra(hObject, handles)
fprintf(handles.serConn,'[TMNGR]');
alvo = ReceberConfigPosicao(hObject, handles);
%alvo
set(handles.edtGRAlvo, 'String',num2str(alvo));
drawnow;
converteTmpPulsoParaGraus_Callback(handles.edtGRAlvo, 0, handles);
%atual
fprintf(handles.serConn,'[GF]');
ObterFeedBackJunta(hObject, handles);


%---
function comandoGarraSemiAberta(hObject, handles)
fprintf(handles.serConn,'[T90GR]');
alvo = ReceberConfigPosicao(hObject, handles);
%alvo
set(handles.edtGRAlvo, 'String',num2str(alvo));
drawnow;
converteTmpPulsoParaGraus_Callback(handles.edtGRAlvo, 0, handles);
comandoCTZ('GR', hObject, handles);


%--- junta = J0, J1, J2, J3, J4 ou GR
function comandoCTZ(junta, hObject, handles)
fprintf(handles.serConn,['[T90' junta ']']);
alvo = ReceberConfigPosicao(hObject, handles);
%alvo
campoEditAlvo = ['edt' junta 'Alvo'];
set(handles.(campoEditAlvo),'String',num2str(alvo));
drawnow;
converteTmpPulsoParaGraus_Callback(handles.(campoEditAlvo), 0, handles);
%atual
fprintf(handles.serConn,['[CTZ' junta ']']);
ObterFeedBackJunta(hObject, handles);


%---
function comandoRepouso(hObject, handles)
global juntas
for i=1:6
    fprintf(handles.serConn,['[TRP' juntas(i,:) ']']);
    alvo = ReceberConfigPosicao(hObject, handles);
    campoEditAlvo = ['edt' juntas(i,:) 'Alvo'];
    set(handles.(campoEditAlvo),'String',num2str(alvo));
    drawnow;
    converteTmpPulsoParaGraus_Callback(handles.(campoEditAlvo), 0, handles);
end

%Atual
fprintf(handles.serConn,'[RPS]');
ObterFeedBackMultiJuntas(hObject, handles);


%---
function comandoDesligarServos(hObject, handles)
global juntas
for i=1:6
    campoEditAlvo = ['edt' juntas(i,:) 'Alvo'];
    set(handles.(campoEditAlvo),'String',num2str(0));
    drawnow;
    converteTmpPulsoParaGraus_Callback(handles.(campoEditAlvo), 0, handles);
end
fprintf(handles.serConn,'[JSTA0000B0000C0000D0000E0000G0000]');
ObterFeedBackMultiJuntas(hObject, handles);


%---
function comandoObterPosicoesAtuais(hObject, handles)
fprintf(handles.serConn, '[JST]');
ObterFeedBackMultiJuntas(hObject, handles);


%---
function comandoPosicionarTodasJuntas(hObject, handles)
global juntas
cmdJST = '[JSTA0000B0000C0000D0000E0000G0000]';
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
    % monta o JST
    alvo = str2double(get(handles.(['edt' juntas(i,:) 'Alvo']),'String'));
    idxPosJunta = 6+5*(i-1);
    cmdJST(idxPosJunta:idxPosJunta+3) = sprintf('%04d',alvo);
end

fprintf(handles.serConn, cmdJST);
ObterFeedBackMultiJuntas(hObject, handles);


%--- Junta = J0, J1,...,J4, GR    ou  A, B, C, D, E, G; alvo: valor da
%posi��o em microssegundos
function comandoPosicionarJunta(junta, alvo, hObject, handles)
global juntas
juntasIdJST = 'ABCDEG';
idxJunta = 0;
for i = 1:6
   if strcmp(junta, juntas(i,:)) || strcmp(junta, juntasIdJST(i))
       idxJunta = i;
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
% monta o JST
cmdJST = ['[JST' juntasIdJST(idxJunta) sprintf('%04d',alvo) ']'];

fprintf(handles.serConn, cmdJST);
ObterFeedBackMultiJuntas(hObject, handles);



%---
function comandoLED(hObject, handles)

cmdLED = '[LED00000000]';

for i=5:12
    cmdLED(i) = num2str(get(handles.(['tbLEDP' num2str(12-i)]),'Value'));
end
fprintf(handles.serConn,cmdLED);
ObterRespostaCmdLED(hObject, handles);


%---
function comandoLEDSemParam(hObject, handles)
fprintf(handles.serConn,'[LED]');
ObterRespostaCmdLED(hObject, handles);


%--- comando = TMX, TMN, T90 ou TRP,   junta = J0, J1,...,J4, GR;
%    valorASetar > 0 seta valor; valorASetar = 0 apenas puxa valor da placa
%    de controle
function ComandoPosLimite(comando, junta, valorASetar, hObject, handles)

switch(comando)
    case 'TMX'
        idxCol = 1;
    case 'TMN'
        idxCol = 2;
    case 'T90'
        idxCol = 3;
    case 'TRP'
        idxCol = 4;
end

switch(junta)
    case {'J0','J1','J2','J3','J4'}
        idxLinha = str2double(junta(2))+1;
    case 'GR'
        idxLinha = 6;
end

if (valorASetar > 0)
    strValorASetar = sprintf('%04d',valorASetar);
    fprintf(handles.serConn,['[' comando junta strValorASetar ']']);
else
    fprintf(handles.serConn,['[' comando junta ']']);
end
valor = ReceberConfigPosicao(hObject, handles);

tabelaPosLimitesData = get(handles.tabelaPosLimites,'Data');
tabelaPosLimitesData(idxLinha,idxCol) = valor;
set(handles.tabelaPosLimites, 'Data', tabelaPosLimitesData);


%--- comando = VEL, ACL; junta = J0, J1,...,J4, GR;
%    valorASetar >= 0 seta valor; valorASetar = -1 apenas puxa valor da placa
%    de controle
function comandoVELOuACL(comando, junta, valorASetar, hObject, handles)
if valorASetar >= 0
    strValorASetar = sprintf('%04d',valorASetar);
    fprintf(handles.serConn,['[' comando junta strValorASetar ']']);
else
    fprintf(handles.serConn,['[' comando junta ']']);
end
ObterRespostaVEL_ACL(hObject, handles);


%--- comando = FRS ou CSB; Com FRS, strValorConfig = 0 (sem feedback), 1
%(Posi��es correntes das juntas como feedback) ou 2(Sinal de movimento como
%feedback). Com CSB, strValorConfig = 0(sem bloqueio de envio de comandos
%quando as juntas estiverem em movimento) ou 1 (com bloqueio de envio de
%comandos enquanto as juntas estiverem em movimento). Se strValorConfig for
%vazio (''), apenas � acionado o comando FRS ou CSB sem par�metro.
function comandoFRSOuCSB(comando, strValorConfig, hObject, handles)
if isempty(strValorConfig)
    cmdConfig = ['[' comando ']'];
else
    cmdConfig = ['[' comando strValorConfig ']'];
end
fprintf(handles.serConn, cmdConfig);
ObterRespostaFRS_CSB(hObject, handles);




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
    y = valorGraus;
    x = (y-b)/a;
    x = round(x);
    if(x > handles.tempoPulsoMax(idxJunta))
        x = handles.tempoPulsoMax(idxJunta);
    elseif(x < handles.tempoPulsoMin(idxJunta))
        x = handles.tempoPulsoMin(idxJunta);
    end
    valorTempoPulso = x;
    
    set(handles.(campoTmpPulso), 'String', num2str(valorTempoPulso));
    drawnow;
    y = a * x + b;

    valorGraus = y;

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
    a = handles.coeffAng(idxJunta);
    b = handles.offsetAng(idxJunta);
    x = valorTempoPulso;

    y = a * x + b;

    valorGraus = y;

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
