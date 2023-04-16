import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ChatComponent } from './chat.component';
import { HttpClientModule } from '@angular/common/http';
import { ChatService } from './chat.service';
import { ReactiveFormsModule } from '@angular/forms';
import { DatabaseModule } from '@angular/fire/database';
import { initializeApp, provideFirebaseApp } from '@angular/fire/app';
import { environment } from 'src/environments/environment';
import { AngularFireModule } from '@angular/fire/compat';
import { RouterTestingModule } from '@angular/router/testing';
describe('ChatComponent', () => {
  let component: ChatComponent;
  let fixture: ComponentFixture<ChatComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [HttpClientModule, ReactiveFormsModule, DatabaseModule,  provideFirebaseApp(() => initializeApp(environment.firebase)),  AngularFireModule.initializeApp(environment.firebase), RouterTestingModule],
      declarations: [ ChatComponent ],
      providers: [ChatService]
    })
    .compileComponents();

    fixture = TestBed.createComponent(ChatComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
