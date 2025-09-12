
function  dirtion() %%选择接口
switch 6 % 修改索引 选择不同功能
    
   case 1
        numendwiter() %%端口命名
   case 2
        clas2clas() %% 模块间连线
   case 3
         MaskCopy()%  复制模块的Mask 标定量
   case 4 
        mode2set()%   修改模块形状
    case 5
        MaskDaty( ) % Mask格式转换   
    case 6
        markfromwos(   1  )%根据输出、输入模块制作fromworks模块 1 输入 2输出 3输入输出
    case 7
        arangesystem()%整理模块布局
     case 8
        markfromSIM( )%根据"_Sim"制作fromworks模块
   
end
%% 1
function  numendwiter()%%端口命名
global  ii
if ii<2
    ii=2
else set_param(gcb,'Port',num2str(ii))
ii=ii+1
end
%% 2
function  clas2clas( )%% 模块间连线
pathe='IPB_5ms_NewValveActuation/IPB_5ms_NewValveActuation'
inpu=['IPB_ValveTargets','/6']
putp=['IPB_ValveController','/22']
add_line(pathe,inpu,putp,'autorouting','on')
%% 3
function  MaskCopy( )%  复制模块的Mask 标定量 %%来去都先要有Mask

lai =Simulink.Mask.get('HalUintCtrl/HydCtrlEst/EV_AV_Unit');
% Simulink.Mask.create('csv/VCP_OneValve/VCP_StateMachine');
qu=Simulink.Mask.get('HalUintCtrl/HydCtrlEst');

for ii=1:numel(lai.Parameters)
laiparam=lai.getParameter(lai.Parameters(1, ii).Name);
 %if regexpi(lai.Parameters(1, ii).Name,'.*_Duration')%阀策略信号、压力目标信号名称统一
%                  Blocks{i,1}= regexprep( Blocks{i,1},'T_','');
%                
%                   Blocks{i,1}=[Blocks{i,1},'_Duration']
% end


a=qu.addParameter(laiparam);

end

%% 4
function  mode2set( )%   修改模块形状
a=get(gcbh);
amxl=max(a.Ports)/2*35;

px=(a.Position(1)+a.Position(3))/2;
py=(a.Position(2)+a.Position(4))/2;
a.Position(1)=min(px-amxl*0.618/2,a.Position(1));
a.Position(3)=max(px+amxl*0.618/2,a.Position(3));

a.Position(2)=py-amxl;
a.Position(4)=py+amxl;
set_param(gcb,'Position',a.Position);
%% 5
function  MaskDaty( )%  Mask格式转换
clear
clc
lai =Simulink.Mask.get(gcb);



for ii=1:numel(lai.Parameters)
    laiparam=lai.Parameters(ii);
    
laiparam.set('Type','edit','Value',laiparam.Value);
end
%% 6
function  markfromwos( asss)%根据输出、输入模块制作fromworks模块  1 输入 2输出 3输入输出
Path= gcs;
InportCell = find_system(Path,'SearchDepth','1','BlockType','Inport'); 
OutportCell = find_system(Path,'SearchDepth',1,'BlockType','Outport');  %获取顶层Inport模块路径


if mod(asss,2)
     for i = 1:length(InportCell)   
    InportName = get_param(InportCell{i},'Name');  
    InportName=[InportName '_sim'];% 模块名称 
     InportPosition= get_param(InportCell{i},'Position'); 
    aaas=[700 0 500 0 ];
    InportPosition=InportPosition-aaas;
Inport_handle=add_block('simulink/Sources/From Workspace',[Path,'/' ,InportName]);
set_param(Inport_handle,'Position',InportPosition,'VariableName',InportName);

     end
end
if asss~=1
 for i = 1:length(OutportCell)   
     OutportName = get_param(OutportCell{i},'Name');  
     OutportName=[OutportName '_sim'];% 模块名称 
    OutportPosition= get_param(OutportCell{i},'Position'); 
    aaas=[300 0 500 0 ];
    bbbs=[500 0 700 0 ];
    OutportPosition=OutportPosition+aaas;

    Outport_handle=add_block('simulink/Sources/From Workspace',[Path,'/' ,OutportName]);
    set_param(Outport_handle,'Position',OutportPosition,'VariableName',OutportName);
    Outport_handle=add_block('simulink/Ports & Subsystems/Out1',[Path,'/' ,OutportName,'_Sim']);
    set_param(Outport_handle,'position',OutportPosition+bbbs);
    %连线
    add_line(Path,[OutportName ,'/1'],[OutportName ,'_Sim','/1']);
    LineHandleStruct = get(Outport_handle,'LineHandles');
    LineHandle = LineHandleStruct.Inport;
    set(LineHandle,'Name',[OutportName '_t']) 
 end
end
%% 7
function arangesystem()%整理模块布局
Simulink.BlockDiagram.arrangeSystem(gcb);

lineHandles=find_system(gcbh,'FindAll','On','SearchDepth',1,'Type','Line');
Simulink.BlockDiagram.routeLine(lineHandles);%整理连线布局
%% 8
function markfromSIM( )%根据"_Sim"制作fromworks模块
alll=evalin('base', 'whos');


OutportPosition=[0 0 120  40];
bbbs=[180 0 180 0 ];
nestone=[0 90 0 90  ];
 Path= gcs;
 add_block('simulink/Ports & Subsystems/Subsystem',[Path,'/SIM' ]);
 Path=[Path,'/SIM' ];
for i=1:length(alll)
     xname=alll(i).name;
    if  regexpi(alll(i).name,'.*_sim')
        Inport_handle=add_block('simulink/Sources/From Workspace',[Path,'/' ,xname]);
set_param(Inport_handle,'Position',OutportPosition,'VariableName',xname)
Outport_handle=add_block('simulink/Ports & Subsystems/Out1',[Path,'/' ,xname,'_Sim']);
   set_param(Outport_handle,'position',OutportPosition+bbbs);
    %连线
 add_line(Path,[xname ,'/1'],[xname ,'_Sim','/1']);
  LineHandleStruct = get(Outport_handle,'LineHandles');
    LineHandle = LineHandleStruct.Inport;
    set(LineHandle,'Name',[xname]) ;
    Simulink.sdi.markSignalForStreaming(LineHandle,'on');
    OutportPosition=OutportPosition+nestone;
 
    end

end
 eval(['clear',' ' ,'alll']);%去除原有信号