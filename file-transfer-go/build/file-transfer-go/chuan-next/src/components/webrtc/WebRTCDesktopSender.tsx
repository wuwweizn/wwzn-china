"use client";

import React, { useState, useCallback, useEffect } from 'react';
import { Button } from '@/components/ui/button';
import { Share, Monitor,  Play, Square, Repeat } from 'lucide-react';
import { useToast } from '@/components/ui/toast-simple';
import { useDesktopShareBusiness } from '@/hooks/desktop-share';
import RoomInfoDisplay from '@/components/RoomInfoDisplay';
import { ConnectionStatus } from '@/components/ConnectionStatus';

interface WebRTCDesktopSenderProps {
  className?: string;
  onConnectionChange?: (connection: any) => void;
}

export default function WebRTCDesktopSender({ className, onConnectionChange }: WebRTCDesktopSenderProps) {
  const [isLoading, setIsLoading] = useState(false);
  const { showToast } = useToast();

  // 使用桌面共享业务逻辑
  const desktopShare = useDesktopShareBusiness();

  // 通知父组件连接状态变化
  useEffect(() => {
    if (onConnectionChange && desktopShare.webRTCConnection) {
      onConnectionChange(desktopShare.webRTCConnection);
    }
  }, [onConnectionChange, desktopShare.isWebSocketConnected, desktopShare.isPeerConnected, desktopShare.isConnecting]);

  // 复制房间代码
  const copyCode = useCallback(async (code: string) => {
    try {
      await navigator.clipboard.writeText(code);
      showToast('房间代码已复制到剪贴板', 'success');
    } catch (error) {
      console.error('复制失败:', error);
      showToast('复制失败，请手动复制', 'error');
    }
  }, [showToast]);

  // 创建房间
  const handleCreateRoom = useCallback(async () => {
    try {
      setIsLoading(true);
      console.log('[DesktopShareSender] 用户点击创建房间');
      
      const roomCode = await desktopShare.createRoom();
      console.log('[DesktopShareSender] 房间创建成功:', roomCode);
      
      showToast(`房间创建成功！代码: ${roomCode}`, 'success');
    } catch (error) {
      console.error('[DesktopShareSender] 创建房间失败:', error);
      const errorMessage = error instanceof Error ? error.message : '创建房间失败';
      showToast(errorMessage, 'error');
    } finally {
      setIsLoading(false);
    }
  }, [desktopShare, showToast]);

  // 开始桌面共享
  const handleStartSharing = useCallback(async () => {
    try {
      setIsLoading(true);
      console.log('[DesktopShareSender] 用户点击开始桌面共享');
      
      await desktopShare.startSharing();
      console.log('[DesktopShareSender] 桌面共享开始成功');
      
      showToast('桌面共享已开始', 'success');
    } catch (error) {
      console.error('[DesktopShareSender] 开始桌面共享失败:', error);
      const errorMessage = error instanceof Error ? error.message : '开始桌面共享失败';
      showToast(errorMessage, 'error');
    } finally {
      setIsLoading(false);
    }
  }, [desktopShare, showToast]);

  // 切换桌面
  const handleSwitchDesktop = useCallback(async () => {
    try {
      setIsLoading(true);
      console.log('[DesktopShareSender] 用户点击切换桌面');
      
      await desktopShare.switchDesktop();
      console.log('[DesktopShareSender] 桌面切换成功');
      
      showToast('桌面切换成功', 'success');
    } catch (error) {
      console.error('[DesktopShareSender] 切换桌面失败:', error);
      const errorMessage = error instanceof Error ? error.message : '切换桌面失败';
      showToast(errorMessage, 'error');
    } finally {
      setIsLoading(false);
    }
  }, [desktopShare, showToast]);

  // 停止桌面共享
  const handleStopSharing = useCallback(async () => {
    try {
      setIsLoading(true);
      console.log('[DesktopShareSender] 用户点击停止桌面共享');
      
      await desktopShare.stopSharing();
      console.log('[DesktopShareSender] 桌面共享停止成功');
      
      showToast('桌面共享已停止', 'success');
    } catch (error) {
      console.error('[DesktopShareSender] 停止桌面共享失败:', error);
      const errorMessage = error instanceof Error ? error.message : '停止桌面共享失败';
      showToast(errorMessage, 'error');
    } finally {
      setIsLoading(false);
    }
  }, [desktopShare, showToast]);

  return (
    <div className={`space-y-4 sm:space-y-6 ${className || ''}`}>
      <div className="bg-white/80 backdrop-blur-sm rounded-xl p-4 sm:p-6 shadow-lg border border-white/20 animate-fade-in-up">
        {!desktopShare.connectionCode ? (
          // 创建房间前的界面
          <div className="space-y-6">
            {/* 功能标题和状态 */}
            <div className="flex items-center justify-between mb-6">
              <div className="flex items-center space-x-3">
                <div className="w-10 h-10 bg-gradient-to-br from-purple-500 to-indigo-500 rounded-xl flex items-center justify-center">
                  <Monitor className="w-5 h-5 text-white" />
                </div>
                <div>
                  <h2 className="text-lg font-semibold text-slate-800">共享桌面</h2>
                  <p className="text-sm text-slate-600">分享您的屏幕给其他人</p>
                </div>
              </div>
              
              <ConnectionStatus 
                currentRoom={desktopShare.connectionCode ? { code: desktopShare.connectionCode, role: 'sender' } : null}
              />
            </div>

            <div className="text-center py-12">
              <div className="w-20 h-20 mx-auto mb-6 bg-gradient-to-br from-purple-100 to-indigo-100 rounded-full flex items-center justify-center">
                <Monitor className="w-10 h-10 text-purple-500" />
              </div>
              <h3 className="text-lg font-semibold text-slate-800 mb-4">创建桌面共享房间</h3>
              <p className="text-slate-600 mb-8">创建房间后将生成分享码，等待接收方加入后即可开始桌面共享</p>
              
              <Button
                onClick={handleCreateRoom}
                disabled={isLoading || desktopShare.isConnecting}
                className="px-8 py-3 bg-gradient-to-r from-purple-500 to-indigo-500 hover:from-purple-600 hover:to-indigo-600 text-white text-lg font-medium rounded-xl shadow-lg"
              >
                {isLoading ? (
                  <>
                    <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-white mr-2"></div>
                    创建中...
                  </>
                ) : (
                  <>
                    <Share className="w-5 h-5 mr-2" />
                    创建桌面共享房间
                  </>
                )}
              </Button>
            </div>
          </div>
        ) : (
          // 房间已创建，显示取件码和等待界面
          <div className="space-y-6">
            {/* 功能标题和状态 */}
            <div className="flex items-center justify-between mb-6">
              <div className="flex items-center space-x-3">
                <div className="w-10 h-10 bg-gradient-to-br from-purple-500 to-indigo-500 rounded-xl flex items-center justify-center">
                  <Monitor className="w-5 h-5 text-white" />
                </div>
                <div>
                  <h2 className="text-lg font-semibold text-slate-800">共享桌面</h2>
                  <p className="text-sm text-slate-600">房间代码: {desktopShare.connectionCode}</p>
                </div>
              </div>
              
              <ConnectionStatus 
                currentRoom={{ code: desktopShare.connectionCode, role: 'sender' }}
              />
            </div>

            {/* 桌面共享控制区域 */}
            {desktopShare.canStartSharing && (
              <div className="bg-white/80 backdrop-blur-sm rounded-xl p-4 border border-slate-200 mb-6">
                <div className="flex items-center justify-between mb-3">
                  <h4 className="text-lg font-medium text-slate-800 flex items-center">
                    <Monitor className="w-5 h-5 mr-2" />
                    桌面共享控制
                  </h4>
                  {desktopShare.isSharing && (
                    <div className="flex items-center space-x-1 bg-emerald-100 text-emerald-700 px-2 py-1 rounded-md">
                      <div className="w-2 h-2 bg-emerald-500 rounded-full animate-pulse"></div>
                      <span className="font-medium">共享中</span>
                    </div>
                  )}
                </div>
                
                <div className="space-y-4">
                  {!desktopShare.isSharing ? (
                    <div className="space-y-3">
                      <Button
                        onClick={handleStartSharing}
                        disabled={isLoading || !desktopShare.isPeerConnected}
                        className={`w-full px-8 py-3 text-lg font-medium rounded-xl shadow-lg ${
                          desktopShare.isPeerConnected 
                            ? 'bg-gradient-to-r from-purple-500 to-indigo-500 hover:from-purple-600 hover:to-indigo-600 text-white' 
                            : 'bg-gray-300 text-gray-500 cursor-not-allowed'
                        }`}
                      >
                        <Play className="w-5 h-5 mr-2" />
                        {isLoading ? '启动中...' : '选择并开始共享桌面'}
                      </Button>
                      
                      {!desktopShare.isPeerConnected && (
                        <div className="text-center">
                          <p className="text-sm text-gray-500 mb-2">
                            等待接收方加入房间建立P2P连接...
                          </p>
                          <div className="flex items-center justify-center space-x-2">
                            <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-purple-500"></div>
                            <span className="text-sm text-purple-600">正在等待连接</span>
                          </div>
                        </div>
                      )}
                    </div>
                  ) : (
                    <div className="space-y-4">
                      <div className="flex items-center justify-center space-x-2 text-green-600 mb-4">
                        <Play className="w-5 h-5" />
                        <span className="font-semibold">桌面共享进行中</span>
                      </div>
                      <div className="flex justify-center space-x-3">
                        <Button
                          onClick={handleSwitchDesktop}
                          disabled={isLoading}
                          variant="outline"
                          size="sm"
                        >
                          <Repeat className="w-4 h-4 mr-2" />
                          {isLoading ? '切换中...' : '切换桌面'}
                        </Button>
                        <Button
                          onClick={handleStopSharing}
                          disabled={isLoading}
                          variant="destructive"
                          size="sm"
                        >
                          <Square className="w-4 h-4 mr-2" />
                          {isLoading ? '停止中...' : '停止共享'}
                        </Button>
                      </div>
                    </div>
                  )}
                </div>
              </div>
            )}

            {/* 房间信息显示 */}
            <RoomInfoDisplay
              code={desktopShare.connectionCode}
              link={`${typeof window !== 'undefined' ? window.location.origin : ''}?type=desktop&mode=receive&code=${desktopShare.connectionCode}`}
              icon={Monitor}
              iconColor="from-emerald-500 to-teal-500"
              codeColor="from-purple-600 to-indigo-600"
              title="房间码生成成功！"
              subtitle="分享以下信息给观看方"
              codeLabel="房间代码"
              qrLabel="扫码观看"
              copyButtonText="复制房间代码"
              copyButtonColor="bg-purple-500 hover:bg-purple-600"
              qrButtonText="使用手机扫码快速观看"
              linkButtonText="复制链接"
              onCopyCode={() => copyCode(desktopShare.connectionCode)}
              onCopyLink={() => {
                const link = `${window.location.origin}?type=desktop&mode=receive&code=${desktopShare.connectionCode}`;
                navigator.clipboard.writeText(link);
                showToast('观看链接已复制', 'success');
              }}
            />
          </div>
        )}
      </div>

    </div>
  );
}
