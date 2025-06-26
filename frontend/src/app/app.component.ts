import { Component, OnInit } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { HttpClient } from '@angular/common/http';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet],
  templateUrl: './app.component.html',
  styleUrl: './app.component.css'
})
export class AppComponent implements OnInit {
  title = 'frontend';
  dbStatus: string = '';

  constructor(private http: HttpClient) {}

  ngOnInit(): void {
    // `DB_API_HOST` será reemplazado por el proceso de build (esbuild --define)
    const host = (typeof DB_API_HOST !== 'undefined' && DB_API_HOST) ? DB_API_HOST : '';
    const endpoint = `${host}/db-check`;
    this.http.get(endpoint).subscribe({
      next: () => (this.dbStatus = 'Conexión exitosa'),
      error: () => (this.dbStatus = 'Error de conexión')
    });
  }
}
