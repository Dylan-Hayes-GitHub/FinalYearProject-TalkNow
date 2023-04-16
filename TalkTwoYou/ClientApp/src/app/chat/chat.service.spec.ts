import { TestBed } from '@angular/core/testing';

import { ChatService } from './chat.service';
import { HttpClientModule } from '@angular/common/http';
import { environment } from 'src/environments/environment';
import { AngularFireModule } from '@angular/fire/compat';
import { DatabaseModule } from '@angular/fire/database';
import { initializeApp, provideFirebaseApp } from '@angular/fire/app';



describe('ChatService', () => {
  let service: ChatService;

  beforeEach(() => {
    TestBed.configureTestingModule({
      imports: [HttpClientModule,  DatabaseModule,  provideFirebaseApp(() => initializeApp(environment.firebase)),  AngularFireModule.initializeApp(environment.firebase)
      ],
    });
    service = TestBed.inject(ChatService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
