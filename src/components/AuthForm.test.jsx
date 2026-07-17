import React from 'react'
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import AuthForm from './AuthForm'

describe('AuthForm', () => {
  it('renders login form by default', () => {
    render(<AuthForm onSignedIn={() => {}} />)

    expect(screen.getByRole('heading', { name: '로그인' })).toBeInTheDocument()
    expect(screen.getByRole('button', { name: '로그인' })).toBeInTheDocument()
  })

  it('toggles to signup mode', async () => {
    const user = userEvent.setup()
    render(<AuthForm onSignedIn={() => {}} />)

    await user.click(screen.getByRole('button', { name: '처음이신가요? 회원가입' }))

    expect(screen.getByRole('heading', { name: '회원가입' })).toBeInTheDocument()
    expect(screen.getByRole('button', { name: '회원가입' })).toBeInTheDocument()
  })
})
