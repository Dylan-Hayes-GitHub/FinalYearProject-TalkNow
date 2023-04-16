import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import {FormsModule, ReactiveFormsModule} from '@angular/forms';
import { HttpClientModule, HTTP_INTERCEPTORS } from '@angular/common/http';
import { RouterModule } from '@angular/router';

import { AppComponent } from './app.component';
import { HomeComponent } from './home/home.component';
import { LoginComponent } from './login/login/login/login.component';
import { AuthInterceptor } from './Auth/auth.interceptor';
import { NavbarComponent } from './navbar/navbar.component';
import { ChatComponent } from './chat/chat.component';
import { PastChatRoomsComponent } from './past-chat-rooms/past-chat-rooms.component';
import { AddFriendComponent } from './add-friend/add-friend.component';
import { StartNewConversationComponent } from './start-new-conversation/start-new-conversation.component';
import { SettingComponent } from './setting/setting.component';
import { initializeApp,provideFirebaseApp } from '@angular/fire/app';
import { environment } from '../environments/environment';
import { provideAuth,getAuth } from '@angular/fire/auth';
import { provideDatabase,getDatabase } from '@angular/fire/database';
import { provideStorage,getStorage } from '@angular/fire/storage';
import { RegisterComponent } from './register/register.component';
import {AngularFireModule} from '@angular/fire/compat';
import { StartNewConversationWaitingRoomComponent } from './start-new-conversation-waiting-room/start-new-conversation-waiting-room.component';
import { RouteGuardGuard } from './Auth/route-guard.guard';
import { StartConversationFromFriendListComponent } from './start-conversation-from-friend-list/start-conversation-from-friend-list.component';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import {MatIconModule} from '@angular/material/icon';
import {MatCardModule} from '@angular/material/card';
import {MatFormFieldModule} from '@angular/material/form-field';
import {MatInputModule} from '@angular/material/input';
import {MatButtonModule} from '@angular/material/button';
import {MatDialogModule} from '@angular/material/dialog';
import {MatProgressSpinnerModule} from '@angular/material/progress-spinner';

import { VerifyUserComponent } from './verify/verify-user/verify-user.component';
import { StartNewConversationPopUpComponent } from './startNewConversationPopup/start-new-conversation-pop-up/start-new-conversation-pop-up.component';
import { ThankYouVerifyComponent } from './verify-thank-you/thank-you-verify/thank-you-verify.component';



@NgModule({
  declarations: [
    AppComponent,
    HomeComponent,
    LoginComponent,
    NavbarComponent,
    ChatComponent,
    PastChatRoomsComponent,
    AddFriendComponent,
    StartNewConversationComponent,
    SettingComponent,
    RegisterComponent,
    StartNewConversationWaitingRoomComponent,
    StartConversationFromFriendListComponent,
    VerifyUserComponent,
    StartNewConversationPopUpComponent,
    ThankYouVerifyComponent,

  ],
  imports: [
    BrowserModule.withServerTransition({ appId: 'ng-cli-universal' }),
    HttpClientModule,
    FormsModule,
    ReactiveFormsModule,
    MatIconModule,
    MatCardModule,
    MatInputModule,
    MatButtonModule,
    MatDialogModule,
    MatProgressSpinnerModule,
    MatFormFieldModule,
    AngularFireModule.initializeApp(environment.firebase),
    RouterModule.forRoot([

      { path: 'chat', component: ChatComponent, canActivate: [RouteGuardGuard]},
      { path: 'login', component: LoginComponent },
      { path: 'verify', component: VerifyUserComponent},
      { path: 'home', component: PastChatRoomsComponent, canActivate: [RouteGuardGuard]},
      { path: 'register', component: RegisterComponent },
      { path: 'thankyou', component: ThankYouVerifyComponent},
      { path: '', component: ChatComponent, canActivate: [RouteGuardGuard] },
      { path: '**', redirectTo: '/login' }


    ]),
    provideFirebaseApp(() => initializeApp(environment.firebase)),
    provideAuth(() => getAuth()),
    provideDatabase(() => getDatabase()),
    provideStorage(() => getStorage()),
    BrowserAnimationsModule
  ]
  ,
  providers: [
    {provide: HTTP_INTERCEPTORS, useClass: AuthInterceptor, multi: true}
  ],
  bootstrap: [AppComponent],
  exports: [
    StartNewConversationPopUpComponent
  ]
})
export class AppModule { }

