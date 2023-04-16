import { ComponentFixture, TestBed } from '@angular/core/testing';

import { StartNewConversationComponent } from './start-new-conversation.component';
import { HttpClientModule } from '@angular/common/http';
import { AngularFireModule } from '@angular/fire/compat';
import { environment } from 'src/environments/environment';
describe('StartNewConversationComponent', () => {
  let component: StartNewConversationComponent;
  let fixture: ComponentFixture<StartNewConversationComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [HttpClientModule, AngularFireModule.initializeApp(environment.firebase)],
      declarations: [ StartNewConversationComponent ]
    })
    .compileComponents();

    fixture = TestBed.createComponent(StartNewConversationComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
